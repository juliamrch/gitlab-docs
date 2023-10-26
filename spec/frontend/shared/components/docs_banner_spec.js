/**
 * @jest-environment jsdom
 */

import { mount } from '@vue/test-utils';
import DocsBanner from '../../../../content/frontend/shared/components/docs_banner.vue';

describe('component: Survey banner', () => {
  const propsData = { text: 'Some text', variant: 'info' };
  let wrapper;

  beforeEach(() => {
    wrapper = mount(DocsBanner, { propsData });
  });

  it('renders a banner', () => {
    expect(wrapper.exists('.banner')).toBe(true);
  });

  it('renders the correct banner text', () => {
    const bannerText = wrapper.find('div');
    expect(bannerText.text()).toEqual(propsData.text);
  });
});
