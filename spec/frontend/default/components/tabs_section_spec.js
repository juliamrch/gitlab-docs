/**
 * @jest-environment jsdom
 */

import { shallowMount } from '@vue/test-utils';
import { GlTabs } from '@gitlab/ui';
import TabsSection from '../../../../content/frontend/default/components/tabs_section.vue';

const getPropsData = (overrides = {}) => {
  const defaultProps = {
    tabTitles: ['Tab 1', 'Tab 2'],
    tabContents: ['Content 1', 'Content 2'],
    responsive: true,
  };

  return { ...defaultProps, ...overrides };
};

describe('content/frontend/default/components/tabs_section.vue', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = shallowMount(TabsSection, {
      propsData: getPropsData(),
    });
  });

  it('does not render tabs with invalid props', () => {
    wrapper = shallowMount(TabsSection, {
      propsData: getPropsData({
        tabTitles: ['Tab 1'],
      }),
    });

    expect(wrapper.findComponent(GlTabs).exists()).toBe(false);
  });

  it('isTabs is true if component is responsive and viewed at wide-width', () => {
    wrapper.setData({ isWideScreen: true });
    const result = wrapper.vm.isTabs;
    expect(result).toBe(true);
  });

  it('isTabs is false if component is responsive and viewed at small-width', () => {
    wrapper.setData({ isWideScreen: false });
    const result = wrapper.vm.isTabs;
    expect(result).toBe(false);
  });

  it('isTabs is true if component is not responsive', () => {
    wrapper = shallowMount(TabsSection, {
      propsData: getPropsData({
        responsive: false,
      }),
    });

    wrapper.setData({ isWideScreen: false });
    const result = wrapper.vm.isTabs;
    expect(result).toBe(true);
  });
});
