/**
 * @jest-environment jsdom
 */

import { mount } from '@vue/test-utils';
import DocsBanner from '../../../../content/frontend/shared/components/docs_banner.vue';

const propsData = { text: 'Some text', show: true };

describe('component: Banner', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = mount(DocsBanner, { propsData });
  });

  it('renders a banner', () => {
    expect(wrapper.exists('.banner')).toBe(true);
  });

  it('renders the correct banner text', () => {
    const bannerText = wrapper.find('span');
    expect(bannerText.text()).toEqual(propsData.text);
  });

  it('renders a close button', () => {
    expect(wrapper.exists('[data-testid="close-icon"]')).toBe(true);
  });

  it('emits a toggle event on mount', () => {
    expect(wrapper.emitted('toggle')[0]).toEqual([true]);
  });

  it('emits a toggle event when the close button is clicked', () => {
    const closeBtn = wrapper.find('[data-testid="close-icon"]');
    closeBtn.trigger('click');
    expect(wrapper.emitted('toggle')[1]).toEqual([false]);
  });
});
