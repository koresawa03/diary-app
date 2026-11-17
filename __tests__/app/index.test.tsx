import { render, screen } from '@testing-library/react-native';

import HomeScreen from '../../app/index';

describe('HomeScreen', () => {
  it('Nicky と表示する', async () => {
    await render(<HomeScreen />);
    expect(screen.getByText('Nicky')).toBeTruthy();
  });
});
