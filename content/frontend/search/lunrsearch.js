import Vue from 'vue';
import LunrPage from './components/lunr_page.vue';
import LunrSearchForm from './components/lunr_search_form.vue';

// Search results page (/search)
document.addEventListener('DOMContentLoaded', () => {
  return new Vue({
    el: '.js-lunrsearch',
    render(createElement) {
      return createElement(LunrPage);
    },
  });
});

// Homepage and interior navbar search forms
document.addEventListener('DOMContentLoaded', () => {
  return new Vue({
    el: '.js-lunr-form',
    components: {
      LunrSearchForm,
    },
    render(createElement) {
      return createElement(LunrSearchForm);
    },
  });
});
