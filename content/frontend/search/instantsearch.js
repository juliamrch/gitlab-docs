import Vue from 'vue';
import {
  AisInstantSearch,
  AisStateResults,
  AisSearchBox,
  AisStats,
  AisPoweredBy,
  AisInfiniteHits,
  AisConfigure,
} from 'vue-instantsearch';
import SearchPage from './components/instantsearch_results.vue';
import { getAlgoliaCredentials, getDocsVersion } from './algolia';

Vue.component(AisInstantSearch.name, AisInstantSearch);
Vue.component(AisSearchBox.name, AisSearchBox);
Vue.component(AisStateResults.name, AisStateResults);
Vue.component(AisStats.name, AisStats);
Vue.component(AisPoweredBy.name, AisPoweredBy);
Vue.component(AisInfiniteHits.name, AisInfiniteHits);
Vue.component(AisConfigure.name, AisConfigure);

const algoliaCredentials = getAlgoliaCredentials();
const docsVersion = getDocsVersion();

document.addEventListener('DOMContentLoaded', () => {
  return new Vue({
    el: '.js-instantsearch',
    render(createElement) {
      return createElement(SearchPage, {
        props: {
          algoliaCredentials,
          docsVersion,
        },
      });
    },
  });
});
