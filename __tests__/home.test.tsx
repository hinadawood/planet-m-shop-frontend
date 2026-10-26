import { render, screen } from '@testing-library/react';
import Home from '../app/page';

describe('Home page', () => {
  it('shows the shop name', () => {
    render(<Home />);
    expect(screen.getByRole('heading', { name: /planet-m shop/i })).toBeInTheDocument();
  });
});
