/**
 * @jest-environment jsdom
 */

import { mount } from '@vue/test-utils';
import DeprecationFilters from '../../../content/frontend/deprecations/components/deprecation_filters.vue';

const propsData = { showAllText: 'Show all', milestonesOptions: [{ value: '160', text: '16.0' }] };
const removalsFilterSelector = '[data-testid="removal-milestone-filter"]';
const breakingFilterSelector = '[data-testid="breaking-filter"]';

describe('component: Deprecations Filter', () => {
  it('Filters are visible', () => {
    const wrapper = mount(DeprecationFilters, { propsData });
    expect(wrapper.find(removalsFilterSelector).isVisible()).toBe(true);
    expect(wrapper.find(breakingFilterSelector).isVisible()).toBe(true);
  });
});
