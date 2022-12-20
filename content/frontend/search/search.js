import { isProduction } from '../default/environment';

/**
 * Loads Algolia connection info.
 *
 * For production, we use the "gitlab" index.
 * All other environments use the "gitlab_testing" index.
 * Both indexes use the same credentials to connect.
 *
 * @see https://www.algolia.com/apps/3PNCFOU757/indices
 */
export const getAlgoliaCredentials = () => {
  return {
    apiKey: 'eef4ee4af5ab6b0d76d1a2f9fc4fab58',
    appId: '3PNCFOU757',
    index: isProduction() ? 'gitlab' : 'gitlab_testing',
  };
};

/**
 * Rewrite absolute URLs as relative.
 *
 * This allows us to query our production index from review apps
 * and local environments but return result links within that copy of the site.
 *
 * Otherwise Algolia returns links to the production site.
 */
export const rewriteAlgoliaResultLinks = (items) => {
  return items.map((item) => ({
    ...item,
    url: item.url.replace('https://docs.gitlab.com', ''),
  }));
};

/**
 * Returns the site version from the docsearch:version metatag.
 */
export const getDocsVersion = () => {
  let docsVersion = 'main';
  if (
    document.querySelector('meta[name="docsearch:version"]') &&
    document.querySelector('meta[name="docsearch:version"]').content.length
  ) {
    docsVersion = document.querySelector('meta[name="docsearch:version"]').content;
  }
  return docsVersion;
};
