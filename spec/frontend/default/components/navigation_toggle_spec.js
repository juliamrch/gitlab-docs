/**
 * @jest-environment jsdom
 */

import { mount } from '@vue/test-utils';
import '../../__mocks__/match_media_mock';
import NavigationToggle from '../../../../content/frontend/default/components/navigation_toggle.vue';

describe('component: Navigation Toggle', () => {
  let wrapper;
  const className = 'some-selector';

  beforeEach(() => {
    const propsData = { targetSelector: [`.${className}`] };

    document.body.innerHTML = `<div class="${className}"></div>`;
    wrapper = mount(NavigationToggle, { propsData });
  });

  it('renders a toggle button', () => {
    expect(wrapper.exists('.nav-toggle')).toBe(true);
  });

  it('renders a toggle label', () => {
    expect(wrapper.find('.label').text()).toEqual('Collapse sidebar');
  });

  it('toggles the navigation when the navigation toggle is clicked', () => {
    const findMenu = () => document.querySelector(`.${className}`);
    jest.spyOn(findMenu().classList, 'toggle');

    wrapper.find('.nav-toggle').trigger('click');
    expect(findMenu().classList.toggle).toHaveBeenCalledWith('active');
  });

  it('toggles the navigation when changing breakpoints', () => {
    // Mock an event of the media query returning negative.
    // This represents the browser not matching "max-width: 1199px,"
    // meaning we have rezised up to a large window.
    wrapper.setData({ width: 500 }); // Mock the starting width.
    let mockChangeMatchMediaEvent = {
      matches: false,
    };
    // Expect an open menu for large windows.
    wrapper.vm.responsiveToggle(mockChangeMatchMediaEvent);
    expect(wrapper.vm.open).toBe(true);

    // Mock resizing down to a small window, where max-width:1199px is true.
    wrapper.setData({ width: 1200 }); // Mock starting width.
    mockChangeMatchMediaEvent = {
      matches: true,
    };
    // The menu should be closed.
    wrapper.vm.responsiveToggle(mockChangeMatchMediaEvent);
    expect(wrapper.vm.open).toBe(false);
  });
});
