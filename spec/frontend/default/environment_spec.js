/**
 * @jest-environment jsdom
 */

import { isArchivesSite } from '../../../content/frontend/default/environment';
import { setWindowPath } from './components/helpers/versions_helper';

describe('isArchivesSite', () => {
  it('returns true for urls with decimal numbers in first path part', () => {
    const testPaths = ['/16.2', '/14.10/search'];

    testPaths.forEach((path) => {
      setWindowPath(path);
      expect(isArchivesSite()).toBe(true);
    });
  });

  it('returns false for urls without decimal numbers in first path part', () => {
    const testPaths = ['/', '/ee'];

    testPaths.forEach((path) => {
      setWindowPath(path);
      expect(isArchivesSite()).toBe(false);
    });
  });
});
