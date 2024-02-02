/* global Vue */
import TabsSection from '../default/components/tabs_section.vue';

document.addEventListener('DOMContentLoaded', () => {
  /**
   * Display featured sections as responsive tabs.
   */
  const tabsetSelector = '.js-tabs';

  document.querySelectorAll(tabsetSelector).forEach((tabset) => {
    const tabTitles = [];
    const tabContents = [];

    tabset.querySelectorAll('.site-section').forEach((tab) => {
      tabTitles.push(tab.dataset.sectionTitle);
      tabContents.push(tab.innerHTML);
    });

    (() =>
      new Vue({
        el: tabsetSelector,
        components: {
          TabsSection,
        },
        render(createElement) {
          return createElement(TabsSection, {
            props: {
              tabTitles,
              tabContents,
              responsive: true,
            },
          });
        },
      }))();
  });
});
