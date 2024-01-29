/**
 * @jest-environment jsdom
 */

import { mount } from '@vue/test-utils';
import DeprecationFilters from '../../../content/frontend/deprecations/components/deprecation_filters.vue';

const propsData = { allMilestones: ['17.0', '15.9', '15.8'] };

describe('component: Deprecations Filter', () => {
  it('Filters are visible', () => {
    const wrapper = mount(DeprecationFilters, { propsData });
    expect(wrapper.find('[data-testid="removal-milestone-filter"]').isVisible()).toBe(true);
    expect(wrapper.find('[data-testid="breaking-filter"]').isVisible()).toBe(true);
  });
});
