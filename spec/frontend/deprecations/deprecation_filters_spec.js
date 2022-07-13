/**
 * @jest-environment jsdom
 */

import { mount } from '@vue/test-utils';
import DeprecationFilters from '../../../content/frontend/deprecations/components/deprecation_filters.vue';

const propsData = { showAllText: 'Show all', milestonesList: [{ value: '160', text: '16.0' }] };
const removalsFilterSelector = '[data-testid="removal-milestone-filter"]';

describe('component: Deprecations Filter', () => {
  it('Filter is visible', () => {
    const wrapper = mount(DeprecationFilters, { propsData });
    expect(wrapper.find(removalsFilterSelector).isVisible()).toBe(true);
  });

  it('Validates a URL parameter', () => {
    const location = {
      ...window.location,
      search: '?removal_milestone=16.0',
      toString: () => {
        return 'http://localhost/ee/update/deprecations.html';
      },
    };
    Object.defineProperty(window, 'location', {
      writable: true,
      value: location,
    });

    const searchParams = new URLSearchParams(window.location.search);
    const versionValue = searchParams.get('removal_milestone').replace(/\./g, '');

    const wrapper = mount(DeprecationFilters, { propsData });
    expect(wrapper.vm.isValidVersion(versionValue)).toBe(true);
  });
});
