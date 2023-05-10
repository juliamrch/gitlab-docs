/* global Vue */
import GoogleSearchForm from './components/google_search_form.vue';
import { activateKeyboardShortcut } from './search_helpers';

document.addEventListener('DOMContentLoaded', () => {
  activateKeyboardShortcut();

  const isHomepage = ['/', '/index.html'].includes(window.location.pathname);

  (() =>
    new Vue({
      el: '.js-google-search-form',
      components: { GoogleSearchForm },
      render(createElement) {
        return createElement(GoogleSearchForm, {
          props: {
            borderless: !isHomepage,
          },
        });
      },
    }))();
});
