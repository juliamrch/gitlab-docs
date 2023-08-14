/**
 * Store recent page views in a cookie.
 */

// Number of links to include in history
export const RECENT_HISTORY_ITEMS = 4;

// Sets a cookie
export const setCookie = (name, value, daysToExpire) => {
  let expires = '';
  if (daysToExpire) {
    const date = new Date();
    date.setTime(date.getTime() + daysToExpire * 24 * 60 * 60 * 1000);
    expires = `; expires=' + ${date.toUTCString()}`;
  }
  document.cookie = `${name}=${value}${expires}; path=/`;
};

// Gets a cookie by name
export const getCookie = (name) => {
  const cookieName = `${name}=`;
  const cookieArray = document.cookie.split(';');
  for (let i = 0; i < cookieArray.length; i += 1) {
    const cookie = cookieArray[i].trim();
    if (cookie.indexOf(cookieName) === 0) {
      return cookie.substring(cookieName.length, cookie.length);
    }
  }
  return null;
};

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
