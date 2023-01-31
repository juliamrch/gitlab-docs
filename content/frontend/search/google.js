import Vue from 'vue';
import GoogleResults from './components/google_results.vue';
import SearchForm from './components/search_form.vue';

const mountVue = (el, Component) => {
  return new Vue({
    el,
    components: { Component },
    render(createElement) {
      return createElement(Component);
    },
  });
};

document.addEventListener('DOMContentLoaded', () => {
  mountVue('.js-google-search', GoogleResults);
  mountVue('.js-search-form', SearchForm);
});
