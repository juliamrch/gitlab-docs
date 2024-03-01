/**
 * Utilities for determining site environment.
 */

export function isProduction() {
  // Handle local development URLs like production.
  const prodHosts = ['docs.gitlab.com', 'localhost', '127.0.0.1'];
  return prodHosts.includes(window.location.hostname);
}

/**
 * Determine if the current page is on an archive site.
 *
 * Archived versions contain a numerical version prefix
 * in the URL (e.g, docs.gitlab.com/16.10).
 *
 * This check needs to be able to run in an offline
 * environment in order to work for all self-hosted sites,
 * so we cannot use fetch() here.
 */
export function isArchivesSite() {
  const parsedUrl = window.location.pathname.split('/');
  const pathPart = parsedUrl[1];

  return /^\d+\.\d+$/.test(pathPart);
}
