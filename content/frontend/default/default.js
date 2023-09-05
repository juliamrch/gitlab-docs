/* global Vue */
import { getNextUntil } from '../shared/dom';
import NavigationToggle from './components/navigation_toggle.vue';
import VersionBanner from './components/version_banner.vue';
import { setupTableOfContents } from './setup_table_of_contents';
import VersionsMenu from './components/versions_menu.vue';
import TabsSection from './components/tabs_section.vue';

/* eslint-disable no-new */
document.addEventListener('DOMContentLoaded', () => {
  setupTableOfContents();

  /**
   * Banner components
   */
  const versionBanner = document.querySelector('#js-version-banner');
  if (versionBanner) {
    const isOutdated = versionBanner.hasAttribute('data-is-outdated');
    const { latestVersionUrl, archivesUrl } = versionBanner.dataset;

    new Vue({
      el: versionBanner,
      components: {
        VersionBanner,
      },
      render(createElement) {
        return createElement(VersionBanner, {
          props: { isOutdated, latestVersionUrl, archivesUrl },
          on: {
            toggleVersionBanner(isVisible) {
              const wrapper = document.querySelector('.wrapper');
              wrapper.classList.toggle('show-banner', isVisible);
            },
          },
        });
      },
    });
  }

  /**
   * Navigation toggle component
   */
  new Vue({
    el: '#js-nav-toggle',
    components: {
      NavigationToggle,
    },
    render(createElement) {
      return createElement(NavigationToggle, {
        props: {
          targetSelector: ['.nav-wrapper', '.main'],
        },
      });
    },
  });

  /**
   * Versions menu component
   */
  new Vue({
    el: '.js-versions-menu',
    components: {
      VersionsMenu,
    },
    render(createElement) {
      return createElement(VersionsMenu);
    },
  });

  /**
   * Tabs component
   */
  const tabsetSelector = '.js-tabs';
  document.querySelectorAll(tabsetSelector).forEach((tabset) => {
    const tabTitles = [];
    const tabContents = [];

    tabset.querySelectorAll('.tab-title').forEach((tab) => {
      tabTitles.push(tab.innerText);
      tabContents.push(getNextUntil(tab, '.tab-title'));
    });

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
          },
        });
      },
    });
  });
});
