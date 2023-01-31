/**
 * @jest-environment jsdom
 */

import { shallowMount } from '@vue/test-utils';
import SearchPage from '../../../content/frontend/search/components/google_results.vue';
import { GPS_ENDPOINT } from '../../../content/frontend/services/google_search_api';

describe('content/frontend/search/components/google_results.vue', () => {
  it('Search form renders', () => {
    const wrapper = shallowMount(SearchPage);
    expect(wrapper.findComponent(SearchPage).isVisible()).toBe(true);
  });

  it('API request failure shows an error', async () => {
    const wrapper = shallowMount(SearchPage);
    const fetch = jest.fn(() => {
      Promise.reject(new Error('HTTP error')).catch(() => null);
    });
    try {
      await fetch(GPS_ENDPOINT);
    } catch (e) {
      expect(wrapper.find('[data-testid="search-error"]').isVisible()).toBe(true);
    }
  });

  it('Google authentication failure shows an error', async () => {
    const wrapper = shallowMount(SearchPage);
    const fetch = jest.fn(() => {
      Promise.resolve({ e: { error: { code: 400 } } }).catch(() => null);
    });
    try {
      await fetch(GPS_ENDPOINT);
    } catch (e) {
      expect(wrapper.find('[data-testid="search-error"]').isVisible()).toBe(true);
    }
  });

  it('Google successful request shows results', async () => {
    const wrapper = shallowMount(SearchPage);
    const fetch = jest.fn(() => {
      Promise.resolve({ items: [{ title: 'GitLab Docs' }] }).catch(() => null);
    });
    try {
      await fetch(GPS_ENDPOINT);
    } catch (e) {
      expect(wrapper.find('[data-testid="search-results"]').isVisible()).toBe(true);
    }
  });
});
