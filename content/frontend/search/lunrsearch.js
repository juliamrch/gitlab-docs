/* global Vue */
import LunrResults from './components/lunr_results.vue';
import SearchForm from './components/lunr_search_form.vue';
import { activateKeyboardShortcut, scrollToQuery } from './search_helpers';

document.addEventListener('DOMContentLoaded', () => {
  scrollToQuery();
  activateKeyboardShortcut();

  // Search results page (/search)
  (() =>
    new Vue({
      el: '.js-lunrsearch',
      render(createElement) {
        return createElement(LunrResults);
      },
    }))();

  // Homepage and interior navbar search forms
  (() =>
    new Vue({
      el: '.js-search-form',
      components: {
        SearchForm,
      },
      render(createElement) {
        return createElement(SearchForm);
      },
    }))();
});
