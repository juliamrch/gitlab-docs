/* global Vue */
import { getNextUntil, isContainedInHeading } from '../shared/dom';
import NavigationToggle from './components/navigation_toggle.vue';
import VersionBanner from './components/version_banner.vue';
import { setupTableOfContents } from './setup_table_of_contents';
import VersionsMenu from './components/versions_menu.vue';
import TabsSection from './components/tabs_section.vue';
import DocsBadges from './components/docs_badges.vue';

/* eslint-disable no-new */
document.addEventListener('DOMContentLoaded', () => {
  setupTableOfContents();

  /**
   * Badge components
   *
   * Badges are typically added in markdown and rendered by Nanoc as spans.
   * Contributor docs have a section-wide badge added here.
   */
  const isContributorDocs = () => {
    const paths = [
      '/ee/development/',
      '/omnibus/development/',
      '/runner/development/',
      '/charts/development/',
    ];
    return paths.some((substr) => window.location.pathname.startsWith(substr));
  };
  // Inject markup for our Contributor docs badge.
  if (isContributorDocs()) {
    document
      .querySelector('h1 a')
      .insertAdjacentHTML(
        'beforebegin',
        ' <span data-component="docs-badges"><span data-type="content" data-value="contribute"></span></span>',
      );
  }
  document.querySelectorAll('[data-component="docs-badges"]').forEach((badgeSet) => {
    const badges = badgeSet.querySelectorAll('span');

    // Get badges that were added to the heading
    const badgesData = Array.from(badges).map((badge) => ({
      type: badge.getAttribute('data-type'),
      text: badge.getAttribute('data-value'),
    }));

    new Vue({
      el: badgeSet,
      components: {
        DocsBadges,
      },
      render(createElement) {
        return createElement(DocsBadges, {
          props: { badgesData, isHeading: isContainedInHeading(badgeSet) },
        });
      },
    });
  });

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
