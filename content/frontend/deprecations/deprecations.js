/* global Vue */
import { compareVersions } from 'compare-versions';
import { getReleaseDates } from '../services/fetch_versions';
import DeprecationFilters from './components/deprecation_filters.vue';

/**
 * Add some helper markup to allow for simpler filter logic.
 */
document.querySelectorAll('.deprecation').forEach((el, index) => {
  el.setAttribute('data-deprecation-id', index + 1);
});

/**
 * Builds an array of announcement milestone options from page content.
 * @return {Array}
 */
const buildMilestonesList = () => {
  const milestones = [];
  document.querySelectorAll('[data-milestone]').forEach((el) => {
    const { milestone } = el.dataset;
    if (!milestones.includes(milestone)) {
      milestones.push(milestone);
    }
  });
  return milestones.sort(compareVersions).reverse();
};

document.addEventListener('DOMContentLoaded', async () => {
  // Create the list of milestones from page content.
  const allMilestones = buildMilestonesList();

  // Populate milestone dates.
  const releaseDates = await getReleaseDates();
  const getMilestoneDateHTML = (milestone) => {
    const msDate = new Date(
      Object.keys(releaseDates).find((key) => releaseDates[key] === milestone),
    );
    const msFormattedDate = msDate.toLocaleString('default', {
      month: 'short',
      year: 'numeric',
    });
    return `&nbsp;<span class="milestone-date">(${msFormattedDate})</span>`;
  };
  // Add dates to removal milestone headings, before the anchor link.
  document.querySelectorAll('.milestone-wrapper h2').forEach((el) => {
    el.querySelector('a.anchor').insertAdjacentHTML(
      'beforebegin',
      getMilestoneDateHTML(el.parentNode.dataset.milestone),
    );
  });
  // Add dates to milestones in the notes section.
  document.querySelectorAll('.deprecation-notes .milestone').forEach((dd) => {
    dd.insertAdjacentHTML(
      'afterend',
      getMilestoneDateHTML(dd.parentNode.querySelector('.milestone').innerText),
    );
  });

  // Initialize the filters Vue component.
  return new Vue({
    el: '.js-deprecation-filters',
    components: {
      DeprecationFilters,
    },
    render(createElement) {
      return createElement(DeprecationFilters, {
        props: {
          allMilestones,
        },
      });
    },
  });
});
