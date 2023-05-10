/**
 * Shared functions for Lunr and Google search.
 */

/**
 * Check URL parameters for search queries.
 *
 * We support "q" as it's a Google standard, and
 * also "query" as it has been long-documented in the
 * GitLab handbook as a Docs search parameter.
 *
 * See https://about.gitlab.com/handbook/tools-and-tips/searching/
 *
 * @returns
 *  The query string if it exists, or an empty string.
 */
export const getSearchQueryFromURL = () => {
  const searchParams = new URLSearchParams(window.location.search);
  return searchParams.get('q') || searchParams.get('query') || '';
};

/**
 * Update URL parameters with search query strings.
 *
 * This allows users to copy a link to search result pages.
 */
export const updateURLParams = (query) => {
  window.history.pushState(null, '', `${window.location.pathname}?q=${query}`);
};
