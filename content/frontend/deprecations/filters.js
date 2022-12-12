import Vue from 'vue';
import { compareVersions } from 'compare-versions';
import DeprecationFilters from './components/deprecation_filters.vue';

/**
 * Add some helper markup to allow for simpler filter logic.
 */
document.querySelectorAll('.deprecation').forEach((el, index) => {
  el.setAttribute('data-deprecation-id', index + 1);
});

/**
 * Builds an array of removal milestone options from page content.
 *
 * Each milestone object contains:
 *   - A text string, used for labels in the select options list.
 *   - A value string, which is the same as the text string, but without periods.
 *     This is used to match the query with CSS classes on deprecations.
 *     CSS classes cannot include periods, so we drop those for this element.
 *
 * @param {String} showAllText
 * @return {Array}
 */
const buildMilestonesList = (showAllText) => {
  let milestones = [];
  document.querySelectorAll('.removal-milestone').forEach((el) => {
    if (!milestones.includes(el.innerText)) {
      milestones.push(el.innerText);
    }
  });
  milestones.sort(compareVersions).reverse();
  milestones = milestones.map((el) => {
    return { value: el.replaceAll('.', ''), text: el };
  });
  milestones.unshift({ value: showAllText, text: showAllText });
  return milestones;
};

document.addEventListener('DOMContentLoaded', () => {
  const showAllText = 'Show all';
  const milestonesOptions = buildMilestonesList(showAllText);

  return new Vue({
    el: '.js-deprecation-filters',
    components: {
      DeprecationFilters,
    },
    render(createElement) {
      return createElement(DeprecationFilters, {
        props: {
          milestonesOptions,
          showAllText,
        },
      });
    },
  });
});
