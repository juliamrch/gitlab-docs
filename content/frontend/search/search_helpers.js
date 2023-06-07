/**
 * Shared functions for Lunr and Google search.
 */

/**
 * Check URL parameters for search parameters.
 *
 * We support "q" for the query string as it's a Google standard,
 * and also "query" as it has been long-documented in the
 * GitLab handbook as a Docs search parameter.
 *
 * See https://about.gitlab.com/handbook/tools-and-tips/searching/
 *
 * @returns
 *  An object containing query parameters.
 */
export const getSearchParamsFromURL = () => {
  const searchParams = new URLSearchParams(window.location.search);
  return {
    qParam: searchParams.get('q') || searchParams.get('query') || '',
    pageParam: searchParams.get('page') || '',
    filterParam: searchParams.get('filters') || '',
  };
};

/**
 * Update URL parameters.
 *
 * This allows users to retrace their steps after a search.
 *
 * @param params Object
 *   Key/value pairs with the param name and value.
 *   Values can be strings or arrays.
 */
export const updateURLParams = (params) => {
  const queryString = Object.entries(params)
    .filter(([, value]) => value !== '' && !(Array.isArray(value) && value.length === 0))
    .map(([key, value]) => `${encodeURIComponent(key)}=${encodeURIComponent(value)}`)
    .join('&');
  window.history.pushState(null, '', `${window.location.pathname}?${queryString}`);
};

/**
 * Search filters.
 *
 * Option properties:
 *   - text: Used for checkbox labels
 *   - value: References values in the "docs-site-section" metatag, which is included each search result.
 *   - id: Machine-friendly version of the text, used for analytics and URL params.
 */
export const SEARCH_FILTERS = [
  {
    title: 'Filter by',
    options: [
      {
        text: 'Installation docs',
        value: 'Install,Subscribe',
        id: 'install',
      },
      {
        text: 'Administration docs',
        value: 'Administer,Subscribe',
        id: 'administer',
      },
      {
        text: 'User docs',
        value: 'Use GitLab,Tutorials,Subscribe',
        id: 'user',
      },
      {
        text: 'Developer (API) docs',
        value: 'Develop',
        id: 'develop',
      },
      {
        text: 'Contributor docs',
        value: 'Contribute',
        id: 'contribute',
      },
    ],
  },
];

/**
 * Convert between filter values and filter IDs.
 *
 * @param Array arr
 *   Selected filters to convert.
 * @param Boolean isToID
 *   true to convert to IDs, false to convert to values
 *
 * @returns Array
 */
export const convertFilterValues = (arr, isToID) => {
  const convertedArr = arr.map((item) => {
    for (const filter of SEARCH_FILTERS) {
      for (const option of filter.options) {
        if ((isToID && option.value === item) || (!isToID && option.id === item)) {
          return isToID ? option.id : option.value;
        }
      }
    }
    return null;
  });
  return convertedArr.filter((item) => item !== null);
};

/**
 * Keyboard shortcuts.
 */
export const activateKeyboardShortcut = () => {
  document.addEventListener('keydown', (e) => {
    // Focus on the search form with the forward slash and S keys.
    const shortcutKeys = ['/', 's'];
    if (!shortcutKeys.includes(e.key) || e.ctrlKey || e.metaKey) return;
    if (/^(?:input|textarea|select|button)$/i.test(e.target.tagName)) return;
    e.preventDefault();
    document.querySelector('input[type="search"]').focus();
  });
};
