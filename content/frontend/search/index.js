import instantsearch from 'instantsearch.js';
import { singleIndex } from 'instantsearch.js/es/lib/stateMappings';
import {
  searchBox,
  refinementList,
  infiniteHits,
  stats,
  poweredBy,
  configure,
} from 'instantsearch.js/es/widgets';
import algoliasearch from 'algoliasearch';

document.addEventListener('DOMContentLoaded', () => {
  const search = instantsearch({
    indexName: 'gitlab',
    searchClient: algoliasearch('3PNCFOU757', '89b85ffae982a7f1adeeed4a90bb0ab1'),
    algoliaOptions: {
      // Filter by tags as described in https://github.com/algolia/docsearch-configs/blob/master/configs/gitlab.json
      filters: 'tags:gitlab<score=3> OR tags:omnibus<score=2> OR tags:runner<score=1>',
    },
    routing: {
      stateMapping: singleIndex('gitlab'),
    },
    searchFunction: (helper) => {
      if (helper.state.query === '') {
        return;
      }
      helper.search();
    },
  });

  search.addWidgets([
    searchBox({
      container: '#searchbox',
      placeholder: 'Search GitLab Documentation',
      showReset: true,
      showLoadingIndicator: true,
    }),

    poweredBy({
      container: '#powered-by',
    }),

    refinementList({
      container: '#refinement-list',
      attribute: 'tags',
      sortBy: ['name:asc', 'isRefined'],
      templates: {
        header: 'Refine your search:',
      },
    }),

    infiniteHits({
      container: '#hits',
      templates: {
        item: document.getElementById('hit-template').innerHTML,
        empty: 'We didn\'t find any results for the search <em>"{{query}}"</em>',
      },
      escapeHits: true,
      showMoreLabel: 'Load more results...',
    }),

    stats({
      container: '#stats',
    }),

    configure({
      // Number of results shown in the search dropdown
      hitsPerPage: 10,
    }),
  ]);

  search.start();
});
