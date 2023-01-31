import Vue from 'vue';
import LunrResults from './components/lunr_results.vue';
import SearchForm from './components/search_form.vue';

// Search results page (/search)
document.addEventListener('DOMContentLoaded', () => {
  return new Vue({
    el: '.js-lunrsearch',
    render(createElement) {
      return createElement(LunrResults);
    },
  });
});

// Homepage and interior navbar search forms
document.addEventListener('DOMContentLoaded', () => {
  return new Vue({
    el: '.js-search-form',
    components: {
      SearchForm,
    },
    render(createElement) {
      return createElement(SearchForm);
    },
  });
});
