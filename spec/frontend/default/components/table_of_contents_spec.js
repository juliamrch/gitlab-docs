/**
 * @jest-environment jsdom
 */

import { shallowMount, mount } from '@vue/test-utils';
import TableOfContents from '../../../../content/frontend/default/components/table_of_contents.vue';
import * as dom from '../../../../content/frontend/shared/dom';
import { flattenItems } from '../../../../content/frontend/shared/toc/flatten_items';
import { createExampleToc } from '../../shared/toc_helper';

const TEST_ITEMS = createExampleToc();

describe('frontend/default/components/table_of_contents', () => {
  let wrapper;

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  beforeEach(() => {
    // jquery is not available in Jest yet so we need to mock this method
    jest.spyOn(dom, 'getOuterHeight').mockReturnValue(100);
  });

  const createComponent = (props = {}, mountFn = shallowMount) => {
    wrapper = mountFn(TableOfContents, {
      propsData: {
        items: TEST_ITEMS,
        ...props,
      },
    });
  };

  const findCollapseButton = () => wrapper.find('[data-testid="collapse"]');
  const findCollapseIcon = () => findCollapseButton().find('svg');
  const findCollapsibleContainer = () => wrapper.find('[data-testid="container"]');
  const findMainList = () => wrapper.find('[data-testid="main-list"]');
  const findMainListItems = () => findMainList().props('items');
  const clickCollapseButton = () => findCollapseButton().trigger('click');

  const expectCollapsed = (isCollapsed = true) => {
    expect(findCollapseButton().attributes('aria-expanded')).toBe(isCollapsed ? undefined : 'true');
    expect(findCollapsibleContainer().props('isCollapsed')).toBe(isCollapsed);
    expect(findCollapseIcon().attributes('data-testid')).toBe(
      isCollapsed ? 'chevron-right-icon' : 'chevron-down-icon',
    );
  };

  it('matches snapshot', () => {
    createComponent();
    expect(wrapper.element).toMatchSnapshot();
  });

  describe('default', () => {
    beforeEach(() => {
      createComponent({}, mount);
    });

    it('renders toc list', () => {
      expect(findMainListItems()).toEqual(flattenItems(TEST_ITEMS));
    });

    it('is initially collapsed', () => {
      expectCollapsed(true);
    });

    describe('when collapse button is pressed', () => {
      beforeEach(() => {
        clickCollapseButton();
      });

      it('starts expanding', () => {
        expect(findCollapsibleContainer().classes('sm-collapsing')).toBe(true);
      });

      it('immediately updates collapse status', () => {
        expectCollapsed(false);
      });

      it('when button pressed again, nothing happens because in the middle of collapsing', () => {
        clickCollapseButton();

        return wrapper.vm.$nextTick(() => {
          expect(findCollapsibleContainer().classes('sm-collapsing')).toBe(true);
          expectCollapsed(false);
        });
      });
    });
  });
});
