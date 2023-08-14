/**
 * @jest-environment jsdom
 */

import { findHighestHeader } from '../../../content/frontend/search/search_helpers';

describe('frontend/search/search_helpers', () => {
  beforeEach(() => {
    // Create a mock DOM environment
    document.body.innerHTML =
      '<!DOCTYPE html><html><body><h2>login to gitlab</h2><h3>AI/ML</h3><h4>repository</h4></body></html>';
  });

  it('should find the correct scrollable header for query "to"', () => {
    const result = findHighestHeader('to');
    expect(result).toBeDefined();
    expect(result.textContent).toBe('login to gitlab');
    expect(result.tagName.toLowerCase()).toBe('h2');
  });

  it('should find the correct scrollable header for query "AI"', () => {
    const result = findHighestHeader('AI');
    expect(result).toBeDefined();
    expect(result.textContent).toBe('AI/ML');
    expect(result.tagName.toLowerCase()).toBe('h3');
  });

  it('should not find any scrollable header for query "FAIL"', () => {
    const result = findHighestHeader('FAIL');
    expect(result).toBeNull();
  });
});
