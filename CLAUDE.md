# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Status
Planet-M Shop frontend: Next.js 15 App Router, React 19, Redux Toolkit, Tailwind 3, Jest + React Testing Library, for a furniture-linens store. Only scaffolding exists (configs, placeholder home page and test). The design below is the approved plan and is **not yet implemented**. The `features/*.feature` files are the requirements: work test-first (scenario → failing test → implementation). The full project plan for both repos is `docs/PLAN.md` in `planet-m-shop-backend`. The API lives in a separate repo, `planet-m-shop-backend` (Spring Boot); its `docs/openapi.yaml` is the contract (copy it to this repo's `docs/`).

## Toolchain
`.tool-versions` pins Node 22 (asdf). If asdf isn't active in the shell, put `~/.asdf/installs/nodejs/22.23.4/bin` first on `PATH`.

## Commands
```bash
cp .env.local.example .env.local      # BACKEND_URL (the nginx gateway, no path), NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY (user supplies the key)
npm install
npm run dev                           # http://localhost:3000; needs the backend stack running behind the gateway at BACKEND_URL
npm test                              # Jest (next/jest, jsdom); tests live in __tests__/
npx jest __tests__/home.test.tsx -t "test name"   # single test
npm run build && npm run lint
```

## Architecture (spans several files; read before changing)
**Request path:** browser → Next.js BFF route handlers in `app/api/**` → nginx gateway (`BACKEND_URL`, `http://localhost:8080` locally) → Spring REST API (`/api/v1`). The browser never calls the gateway or Spring directly, and Stripe secrets never reach it. React Router is not used; routing is Next's file-system router in `app/`.

**Rendering split:** product list and detail pages are async server components (SSR) that call the backend through the server-only `src/bff/backendClient`, with `fetch(..., { next: { revalidate: 60, tags: ['products'] } })`. Product changes made through the BFF call `revalidateTag('products')`. Interactive pieces (category pills, add-to-cart, cart, checkout form, payment redirect) are client components using Redux. The store is created per request in `StoreProvider`, with SSR data passed in as props for hydration. SSR output can be up to 60s stale, so stock is re-checked on add-to-cart through the BFF.

**BFF responsibilities:** hides the backend URL; keeps the guest cart token in an httpOnly cookie (not localStorage); validates payloads with zod before forwarding; maps backend ProblemDetail errors (404/409/400) and gateway 429 rate-limit responses to UI-friendly messages; aggregates calls where useful. It forwards the shopper's IP in `X-Forwarded-For` and an `X-Request-Id` on every backend call (the gateway rate-limits per client IP, so without this all shoppers would share the BFF's limit).

**Auth:** customer accounts with JWT. The BFF stores the access and refresh tokens in httpOnly cookies (never readable by browser JS), attaches `Authorization: Bearer` to backend calls, refreshes on 401, checks `Origin` on mutating routes, and merges the guest cart into the account cart on login. Pages `/login`, `/register`, `/account`, `/account/orders` (protected pages redirect to `/login`). Order history and the order event timeline come from the backend's Cassandra-backed endpoints; the payment-success poll uses the live order status. Category filtering is URL-driven (`?category=living`) so SSR pages are shareable.

**Checkout and payment:** the checkout page has a payment-method form (Credit/Debit card or Afterpay; card preselected). Afterpay is disabled with a hint when the total is outside its limits or the country is unsupported. "Place order" generates a UUID `Idempotency-Key` once per checkout attempt (kept in the checkout slice), reuses it on network retries, regenerates it after a terminal failure or a cart change, and disables the button while a request is pending. The checkout page shows the bill from the backend's `POST /checkout/quote` before any order exists. The BFF forwards the key; on success the browser is redirected to the Stripe-hosted page via `@stripe/stripe-js`, and the success page polls the order until it is PAID (the backend webhook, not the redirect, is the source of truth).

**Conventions:** categories are Bedroom, Dining, Living, Outdoor (rendered as pills with an "All" pill, `aria-pressed` on the active one). Server components are tested by awaiting the component function with `backendClient` mocked; `app/api/**/route.ts` handlers are tested by calling them with `Request` objects in a Jest `node` environment; `next/navigation` is mocked in component tests.
