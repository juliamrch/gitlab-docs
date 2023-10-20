import { setCookie, getCookie } from '../shared/cookies';

/**
 * Store recent page views in a cookie.
 */

// Number of links to include in history
export const RECENT_HISTORY_ITEMS = 4;

// Writes page URLs to a cookie
export const trackPageHistory = () => {
  let pageHistory = [];
  const currentPath = window.location.pathname;
  const cookieValue = getCookie('pageHistory');

  if (cookieValue) {
    pageHistory = JSON.parse(cookieValue);

    // Remove current page URL if it already exists in the history
    const index = pageHistory.findIndex((item) => item.path === currentPath);
    if (index > -1) {
      pageHistory.splice(index, 1);
    }
  }

  // Add the current page URL to the beginning of the history array
  pageHistory.unshift({
    path: currentPath,
    title: document.title.replace(' | GitLab', ''),
  });

  // Keep only the designated amount of pages in history
  if (pageHistory.length > RECENT_HISTORY_ITEMS) {
    pageHistory = pageHistory.slice(0, RECENT_HISTORY_ITEMS);
  }

  // Set a cookie with the history string
  const updatedCookieValue = JSON.stringify(pageHistory);
  setCookie('pageHistory', updatedCookieValue, 365);
};

// Initialize history tracking on pages with titles
document.addEventListener('DOMContentLoaded', () => {
  trackPageHistory();
});
