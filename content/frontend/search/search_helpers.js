/**
 * Shared functions for Lunr and Google search.
 */

/**
 * Check URL parameters for search queries.
 *
 * @returns
 *  The query string if it exists, or an empty string.
 */
export const getSearchQueryFromURL = () => {
  return new URLSearchParams(window.location.search).get('query') || '';
};

/**
 * Update URL parameters with search query strings.
 *
 * This allows users to copy a link to search result pages.
 */
export const updateURLParams = (query) => {
  window.history.pushState(null, '', `${window.location.pathname}?query=${query}`);
};
