/**
 * @jest-environment jsdom
 */

import { shallowMount, mount } from '@vue/test-utils';
import TableOfContents from '../../../../content/frontend/default/components/table_of_contents.vue';
import { flattenItems } from '../../../../content/frontend/shared/toc/flatten_items';
import { createExampleToc } from '../../shared/toc_helper';

const TEST_ITEMS = createExampleToc();

describe('frontend/default/components/table_of_contents', () => {
  let wrapper;

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const createComponent = (props = {}, mountFn = shallowMount) => {
    wrapper = mountFn(TableOfContents, {
      propsData: {
        items: TEST_ITEMS,
        initialCollapsed: true,
        ...props,
      },
    });
  };

  const findCollapseButton = () => wrapper.find('[data-testid="collapse"]');
  const findCollapseIcon = () => findCollapseButton().find('svg');
  const findMainList = () => wrapper.find('[data-testid="main-list"]');
  const findMainListItems = () => findMainList().props('items');

  const expectCollapsed = (isCollapsed = true) => {
    expect(findCollapseButton().attributes('aria-expanded')).toBe(isCollapsed ? undefined : 'true');
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
  });
});
