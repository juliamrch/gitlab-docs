import Vue from 'vue';
import GoogleResults from './components/google_results.vue';
import { activateKeyboardShortcut } from './search_helpers';

document.addEventListener('DOMContentLoaded', () => {
  activateKeyboardShortcut();

  (() =>
    new Vue({
      el: '.js-google-search',
      components: {
        GoogleResults,
      },
      render(createElement) {
        return createElement(GoogleResults);
      },
    }))();
});
