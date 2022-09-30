/**
 * Functions used by both DocSearch and InstantSearch.
 */

export const algoliaAccounts = {
  production: {
    apiKey: 'eef4ee4af5ab6b0d76d1a2f9fc4fab58',
    appId: '3PNCFOU757',
    index: 'gitlab',
  },
  testing: {
    apiKey: 'eef4ee4af5ab6b0d76d1a2f9fc4fab58',
    appId: '3PNCFOU757',
    index: 'gitlab_testing',
  },
};

/**
 * Loads Algolia connection info for a given Crawler.
 *
 * Set the crawler default to 'testing' in order to use
 * the gitlab_testing index. (Don't forget to change it back!)
 */
export const getAlgoliaCredentials = (crawler = 'production') => {
  return algoliaAccounts[crawler];
};

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
