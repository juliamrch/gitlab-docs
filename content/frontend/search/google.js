/* global Vue */
import GoogleSearchForm from './components/google_search_form.vue';
import { activateKeyboardShortcut, scrollToQuery } from './search_helpers';

document.addEventListener('DOMContentLoaded', () => {
  scrollToQuery();
  activateKeyboardShortcut();

  (() =>
    new Vue({
      el: '.js-google-search-form',
      components: { GoogleSearchForm },
      render(createElement) {
        return createElement(GoogleSearchForm, {
          props: {
            numResults: 7,
          },
        });
      },
    }))();
});
