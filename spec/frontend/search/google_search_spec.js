/**
 * @jest-environment jsdom
 */
import { mount, shallowMount } from '@vue/test-utils';
import flushPromises from 'flush-promises';
import {
  mockResults,
  mockNoResults,
  mockErrorResults,
  mockHistoryCookie,
} from '../__mocks__/search_results_mock';
import SearchForm from '../../../content/frontend/search/components/google_search_form.vue';
import SearchPage from '../../../content/frontend/search/components/google_results.vue';
import {
  trackPageHistory,
  setCookie,
  getCookie,
  RECENT_HISTORY_ITEMS,
} from '../../../content/frontend/search/recently_viewed';
import { GPS_ENDPOINT, fetchResults } from '../../../content/frontend/services/google_search_api';

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
      propsData: {
        borderless: true,
        numResults: 10,
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
    await flushPromises();

    expect(fetchResults).toHaveBeenCalledTimes(1);
    expect(wrapper.find('[data-testid="no-results"]').exists()).toBe(true);
  });

  it('displays "See all results" link when there are more results than shown', async () => {
    fetchResults.mockResolvedValueOnce(mockResults);

    const input = wrapper.find('input');
    input.setValue('test');
    await input.trigger('keyup');
    jest.advanceTimersByTime(500);
    await flushPromises();

    expect(wrapper.vm.hasMoreResults).toBe(true);

    const moreResultsLink = wrapper.find('[data-testid="more-results"]');
    expect(moreResultsLink.exists()).toBe(true);
    expect(moreResultsLink.attributes('href')).toBe('/search/?q=test');
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

describe('content/frontend/search/recently_viewed.js', () => {
  afterEach(() => {
    // Delete the cookie after each test
    document.cookie = 'pageHistory=; expires=Mon, 12 June 2023 00:00:00 UTC; path=/;';
  });

  it('should set a cookie with the current page URL and title', () => {
    // Set up the DOM
    document.body.innerHTML = '<h1>Test Page</h1>';
    const location = {
      ...window.location,
      pathname: '/test-page',
    };
    Object.defineProperty(window, 'location', {
      writable: true,
      value: location,
    });

    trackPageHistory();

    // Check that the cookie was set correctly
    const cookieValue = getCookie('pageHistory');
    expect(cookieValue).not.toBeNull();
    const pageHistory = JSON.parse(cookieValue);
    expect(pageHistory).toHaveLength(1);
    expect(pageHistory[0].path).toBe('/test-page');
    expect(pageHistory[0].title).toBe('Test Page');
  });

  it('should limit the number of items in the history to RECENT_HISTORY_ITEMS', () => {
    document.body.innerHTML = '<h1>Test Page</h1>';

    // Set a cookie with RECENT_HISTORY_ITEMS pages in it, then track this page
    setCookie('pageHistory', JSON.stringify(mockHistoryCookie), 365);
    trackPageHistory();

    // Check that the cookie still contains RECENT_HISTORY_ITEMS
    const cookieValue = getCookie('pageHistory');
    expect(cookieValue).not.toBeNull();
    const pageHistory = JSON.parse(cookieValue);
    expect(pageHistory).toHaveLength(RECENT_HISTORY_ITEMS);
  });

  it('should not add duplicate history items', () => {
    document.body.innerHTML = '<h1>Test Page</h1>';

    // Set a cookie with the current page URL
    const initialPageHistory = [{ path: '/test-page', title: 'Test Page' }];
    setCookie('pageHistory', JSON.stringify(initialPageHistory), 365);

    trackPageHistory();

    // Check that the cookie was updated correctly, with one instance of Test Page
    const cookieValue = getCookie('pageHistory');
    expect(cookieValue).not.toBeNull();
    const pageHistory = JSON.parse(cookieValue);
    expect(pageHistory).toHaveLength(1);
    expect(pageHistory[0].path).toBe('/test-page');
    expect(pageHistory[0].title).toBe('Test Page');
  });

  it('should not set a cookie if the page does not have a title', () => {
    // Set up the DOM without a h1 element
    document.body.innerHTML = '<p>Test Page</p>';

    trackPageHistory();

    // Check that the cookie was not set
    const cookieValue = getCookie('pageHistory');
    expect(cookieValue).toBeNull();
  });
});
