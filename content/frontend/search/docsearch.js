import docsearch from '@docsearch/js';
import '@docsearch/css';
import { rewriteAlgoliaResultLinks, getAlgoliaCredentials, getDocsVersion } from './search';

document.addEventListener('DOMContentLoaded', () => {
  const docsVersion = getDocsVersion();
  const algoliaCredentials = getAlgoliaCredentials();

  // eslint-disable-next-line no-undef
  docsearch({
    apiKey: algoliaCredentials.apiKey,
    indexName: algoliaCredentials.index,
    container: '#docsearch',
    appId: algoliaCredentials.appId,
    placeholder: 'Search the docs',
    searchParameters: {
      facetFilters: [`version:${docsVersion}`],
    },
    transformItems(items) {
      return rewriteAlgoliaResultLinks(items);
    },
    resultsFooterComponent({ state }) {
      return {
        type: 'a',
        ref: undefined,
        constructor: undefined,
        key: state.query,
        props: {
          href: `/search/?query=${state.query}`,
          children: `See all results`,
        },
        __v: null,
      };
    },
  });
});
