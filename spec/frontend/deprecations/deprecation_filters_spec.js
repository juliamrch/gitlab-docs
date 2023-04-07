/**
 * @jest-environment jsdom
 */

import { mount } from '@vue/test-utils';
import DeprecationFilters from '../../../content/frontend/deprecations/components/deprecation_filters.vue';

const propsData = { allMilestones: ['17.0', '15.9', '15.8'] };
const removalFilterSelector = '[data-testid="removal-milestone-filter"]';
const breakingFilterSelector = '[data-testid="breaking-filter"]';

describe('component: Deprecations Filter', () => {
  it('Filters are visible', () => {
    const wrapper = mount(DeprecationFilters, { propsData });
    expect(wrapper.find(removalFilterSelector).isVisible()).toBe(true);
    expect(wrapper.find(breakingFilterSelector).isVisible()).toBe(true);
  });
});
