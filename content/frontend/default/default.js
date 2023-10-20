/* global Vue */
import { getNextUntil } from '../shared/dom';
import DocsBanner from '../shared/components/docs_banner.vue';
import NavigationToggle from './components/navigation_toggle.vue';
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
    // Create the link to the latest page by dropping the version number from the URL path.
    const version = document
      .querySelector('meta[name="gitlab-docs-version"]')
      .getAttribute('content');
    const latestURL = window.location.pathname.replace(`/${version}/`, '/');

    new Vue({
      el: versionBanner,
      components: {
        DocsBanner,
      },
      render(createElement) {
        return createElement(DocsBanner, {
          props: {
            text: `This is <a href="https://docs.gitlab.com/archives">archived documentation</a> for GitLab. Go to
          <a href="${latestURL}">the latest</a>.`,
            isSticky: true,
            variant: 'tip',
            dismissible: false,
          },
        });
      },
    });
  }

  const surveyBanner = document.querySelector('#js-survey-banner');
  new Vue({
    el: surveyBanner,
    components: {
      DocsBanner,
    },
    render(createElement) {
      return createElement(DocsBanner, {
        props: { text: surveyBanner.dataset.content, icon: 'tanuki', variant: 'info' },
      });
    },
  });

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
