/* global Vue */
import { isContainedInHeading } from '../shared/dom';
import DocsBadges from './components/docs_badges.vue';

window.addEventListener('load', () => {
  /**
   * Handling for section badges.
   *
   * These badges are added to full site sections,
   * based on the URL paths, and are not included in
   * the source markdown files.
   */
  const sectionBadges = [
    {
      type: 'contribute',
      paths: [
        '/ee/development/',
        '/omnibus/development/',
        '/runner/development/',
        '/charts/development/',
      ],
    },
    {
      type: 'solutions',
      paths: ['/ee/solutions/'],
    },
  ];
  const injectSectionBadge = (badgeType) => {
    if (badgeType.paths.some((substr) => window.location.pathname.startsWith(substr))) {
      document
        .querySelector('h1 a')
        .insertAdjacentHTML(
          'beforebegin',
          ` <span data-component="docs-badges" data-nosnippet><span data-type="content" data-value="${badgeType.type}"></span></span>`,
        );
    }
  };
  sectionBadges.forEach((badgeType) => injectSectionBadge(badgeType));

  /**
   * Handling for Markdown badges.
   *
   * These badges are added from Markdown files
   * and initially rendered as <span> tags.
   */
  document.querySelectorAll('[data-component="docs-badges"]').forEach((badgeSet) => {
    const badges = badgeSet.querySelectorAll('span');
    const badgesData = Array.from(badges).map((badge) => ({
      type: badge.getAttribute('data-type'),
      text: badge.getAttribute('data-value'),
    }));
    (() =>
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
      }))();
  });
});
