import Vue from 'vue';
import { compareVersions } from 'compare-versions';
import DeprecationFilters from './components/deprecation_filters.vue';

/**
 * Builds an array of removal milestone options from page content.
 *
 * Each milestone object contains:
 *   - A text string, used for labels in the select options list.
 *     This also appears as a query string value in the URL when filtering.
 *   - A value string, which is the same as the text string, but without periods.
 *     This is used to match the query with CSS classes on deprecations.
 *     CSS classes cannot include periods, so we drop those for this element.
 *
 * @param {String} showAllText
 *   Label for default/unselected state.
 * @return {Array}
 */
const buildMilestonesList = (showAllText) => {
  let milestones = [];
  document.querySelectorAll('.removal-milestone').forEach(function addOption(el) {
    if (!milestones.includes(el.innerText)) {
      milestones.push(el.innerText);
    }
  });
  milestones.sort(compareVersions).reverse();
  milestones = milestones.map(function addValues(el) {
    return { value: el.replaceAll('.', ''), text: el };
  });
  milestones.unshift({ value: showAllText, text: showAllText });
  return milestones;
};

document.addEventListener('DOMContentLoaded', () => {
  const showAllText = 'Show all';
  const milestonesList = buildMilestonesList(showAllText);

  return new Vue({
    el: '.js-deprecation-filters',
    components: {
      DeprecationFilters,
    },
    render(createElement) {
      return createElement(DeprecationFilters, {
        props: {
          milestonesList,
          showAllText,
        },
      });
    },
  });
});
