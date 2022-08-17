/**
 * @jest-environment jsdom
 */

import { shallowMount } from '@vue/test-utils';
import { GlTabs } from '@gitlab/ui';
import TabsSection from '../../../../content/frontend/default/components/tabs_section.vue';

describe('content/frontend/default/components/tabs_section.vue', () => {
  it('Tabs are visible', () => {
    const propsData = {
      tabTitles: ['Tab one', 'Tab two'],
      tabContents: ['Tab one content', 'Tab two content'],
    };
    const wrapper = shallowMount(TabsSection, { propsData });
    expect(wrapper.findComponent(GlTabs).isVisible()).toBe(true);
  });

  it('validateTabContents', () => {
    const propsData = {
      tabTitles: ['Tab one', ''],
      tabContents: ['Tab one content', 'Tab two content'],
    };
    const wrapper = shallowMount(TabsSection, { propsData });
    expect(wrapper.findComponent(GlTabs).exists()).toBe(false);
  });
});
