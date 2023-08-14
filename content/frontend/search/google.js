/* global Vue */
import GoogleSearchForm from './components/google_search_form.vue';
import { activateKeyboardShortcut, scrollToQuery } from './search_helpers';

document.addEventListener('DOMContentLoaded', () => {
  scrollToQuery();
  activateKeyboardShortcut();

  const { isHomepage } = document.querySelector('body').dataset;

  (() =>
    new Vue({
      el: '.js-google-search-form',
      components: { GoogleSearchForm },
      render(createElement) {
        return createElement(GoogleSearchForm, {
          props: {
            borderless: !isHomepage,
            numResults: 7,
          },
        });
      },
    }))();
});
