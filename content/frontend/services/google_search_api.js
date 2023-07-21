/* global GOOGLE_SEARCH_KEY */

export const GPS_ENDPOINT = 'https://www.googleapis.com/customsearch/v1/siterestrict?';
export const GPS_ID = '97494f9fe316a426d';
export const MAX_RESULTS_PER_PAGE = 10;
export const MAX_TOTAL_RESULTS = 100;

export const fetchResults = async (query, filters, pageNumber, numResults) => {
  if (!query || query.length < 2 || typeof query !== 'string') {
    return [];
  }

  // Construct the query string for additional filters if needed.
  const filterQuery = filters.length
    ? `+more:pagemap:metatags-gitlab-docs-section:${filters.join(',')}`
    : '';

  const response = await fetch(
    GPS_ENDPOINT +
      new URLSearchParams({
        key: GOOGLE_SEARCH_KEY,
        cx: GPS_ID,
        q: `${query}${filterQuery}`.replaceAll(' ', '+'),
        num: numResults,
        start: (pageNumber - 1) * numResults + 1,
      }),
  );
  const results = await response.json();

  // Clean up the title and link on each result.
  if (results.items) {
    results.items = results.items.map((item) => ({
      ...item,
      formattedTitle: item.htmlTitle
        .replace(' | GitLab', '')
        .replace(' | <b>GitLab</b>', '')
        .replace(' ...', '')
        .replaceAll('`', '')
        .trim(),
      relativeLink: item.link.replace('https://docs.gitlab.com/', '/'),
      breadcrumbs: item.pagemap.metatags[0]['gitlab-docs-breadcrumbs'] ?? '',
    }));
  }

  return results;
};
