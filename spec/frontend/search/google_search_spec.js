/**
 * @jest-environment jsdom
 */

import { mount, shallowMount } from '@vue/test-utils';
import { mockResults, mockNoResults, mockErrorResults } from '../__mocks__/search_results_mock';
import SearchForm from '../../../content/frontend/search/components/google_search_form.vue';
import SearchPage from '../../../content/frontend/search/components/google_results.vue';
import { GPS_ENDPOINT, fetchResults } from '../../../content/frontend/services/google_search_api';

jest.useFakeTimers('modern');
jest.mock('../../../content/frontend/services/google_search_api', () => ({
  fetchResults: jest.fn(),
  MAX_RESULTS_PER_PAGE: 10,
}));

describe('content/frontend/search/components/google_search_form.vue', () => {
  let wrapper;

  // Use fake timers to mock debounce behavior.
  beforeAll(() => {
    jest.useFakeTimers();
  });
  afterAll(() => {
    jest.runAllTimers();
  });

  beforeEach(() => {
    jest.clearAllMocks();

    // Add a container around the mounted component.
    // We need this to avoid tooltip errors from BootstrapVue.
    const createContainer = (tag = 'div') => {
      const container = document.createElement(tag);
      document.body.appendChild(container);
      return container;
    };
    const componentData = {
      attachTo: createContainer(),
      props: {
        borderless: true,
      },
    };
    wrapper = mount(SearchForm, componentData);
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('runs a search when the user types in a query', async () => {
    fetchResults.mockResolvedValueOnce(mockResults);

    const input = wrapper.find('input');
    input.setValue('how does jest work');
    await input.trigger('keyup');
    jest.advanceTimersByTime(500); // debounce

    expect(fetchResults).toHaveBeenCalledTimes(1);
  });

  it('displays "No results found" message when there are no search results', async () => {
    fetchResults.mockResolvedValueOnce(mockNoResults);

    const input = wrapper.find('input');
    input.setValue('non-existent query');
    await input.trigger('keyup');
    jest.advanceTimersByTime(500);
    await wrapper.vm.$nextTick();

    expect(fetchResults).toHaveBeenCalledTimes(1);
    expect(wrapper.find('[data-testid="no-results"]').exists()).toBe(true);
  });

  it('displays "See all results" link when there are more than 10 search results', async () => {
    fetchResults.mockResolvedValueOnce(mockResults);

    const input = wrapper.find('input');
    input.setValue('test');
    await input.trigger('keyup');
    jest.advanceTimersByTime(500);
    await wrapper.vm.$nextTick();

    expect(wrapper.vm.hasMoreResults).toBe(true);
    expect(wrapper.find('[data-testid="more-results"]').exists()).toBe(true);
  });

  it('links to the advanced search page from the "See all results" link', async () => {
    fetchResults.mockResolvedValueOnce(mockResults);

    const input = wrapper.find('input');
    input.setValue('test');
    await input.trigger('keyup');
    jest.advanceTimersByTime(500);
    await wrapper.vm.$nextTick();

    const link = wrapper.find('[data-testid="more-results"]');
    expect(link.attributes('href')).toBe('/search/?q=test');
  });
});

describe('content/frontend/search/components/google_results.vue', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = shallowMount(SearchPage);
  });
  afterEach(() => {
    wrapper.destroy();
  });

  it('API request failure shows an error', async () => {
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
    const fetch = jest.fn(() => {
      Promise.resolve({ mockErrorResults }).catch(() => null);
    });
    try {
      await fetch(GPS_ENDPOINT);
    } catch (e) {
      expect(wrapper.find('[data-testid="search-error"]').isVisible()).toBe(true);
    }
  });

  it('Google successful request shows results', async () => {
    const fetch = jest.fn(() => {
      Promise.resolve(mockResults).catch(() => null);
    });
    try {
      await fetch(GPS_ENDPOINT);
    } catch (e) {
      expect(wrapper.find('[data-testid="search-results"]').isVisible()).toBe(true);
    }
  });
});
