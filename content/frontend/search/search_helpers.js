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
  return new URLSearchParams(window.location.search).get('q') || '';
};

/**
 * Update URL parameters with search query strings.
 *
 * This allows users to copy a link to search result pages.
 */
export const updateURLParams = (query) => {
  window.history.pushState(null, '', `${window.location.pathname}?q=${query}`);
};

/**
 * Keyboard shortcuts.
 */
export const activateKeyboardShortcut = () => {
  document.addEventListener('keyup', (e) => {
    // Focus on search form with the forward slash key.
    if (e.key !== '/' || e.ctrlKey || e.metaKey) return;
    if (/^(?:input|textarea|select|button)$/i.test(e.target.tagName)) return;
    e.preventDefault();
    document.querySelector('input[type="search"]').focus();
  });
};
