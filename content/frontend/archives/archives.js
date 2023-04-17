/* global Vue */
import ArchivesPage from './archives_page.vue';

document.addEventListener('DOMContentLoaded', () => {
  return new Vue({
    el: '.js-archives',
    components: {
      ArchivesPage,
    },
    render(createElement) {
      return createElement(ArchivesPage);
    },
  });
});
