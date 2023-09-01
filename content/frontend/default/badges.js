/* global Vue */
import { isContainedInHeading } from '../shared/dom';
import DocsBadges from './components/docs_badges.vue';

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
      ' <span data-component="docs-badges" data-nosnippet><span data-type="content" data-value="contribute"></span></span>',
    );
}
document.querySelectorAll('[data-component="docs-badges"]').forEach((badgeSet) => {
  const badges = badgeSet.querySelectorAll('span');

  // Get badges that were added to the heading
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
