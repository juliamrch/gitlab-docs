/**
 * @jest-environment jsdom
 */

import { shallowMount, createLocalVue } from '@vue/test-utils';
import GlIcon from '../../../../content/frontend/shared/components/gl_icon.vue';
import { iconSizeOptions } from '../../../../content/frontend/shared/constants';

const ICONS_PATH = '/path/to/icons.svg';
const TEST_SIZE = 8;
const TEST_NAME = 'check-circle';

const localVue = createLocalVue();

jest.mock('@gitlab/svgs/dist/icons.svg', () => '/path/to/icons.svg');

describe('GlIcon component', () => {
  let wrapper;
  let consoleSpy;

  const createComponent = (props) => {
    wrapper = shallowMount(GlIcon, {
      propsData: {
        size: TEST_SIZE,
        name: TEST_NAME,
        ...props,
      },
      localVue,
    });
  };

  const validateSize = (size) => GlIcon.props.size.validator(size);
  const validateName = (name) => GlIcon.props.name.validator(name);

  afterEach(() => {
    wrapper.destroy();

    if (consoleSpy) {
      consoleSpy.mockRestore();
    }
  });

  describe('when created', () => {
    beforeEach(() => {
      createComponent();
    });

    it(`shows svg class "s${TEST_SIZE}" and path "${ICONS_PATH}#${TEST_NAME}"`, () => {
      expect(wrapper.html()).toMatchSnapshot();
    });
  });

  describe('size validator', () => {
    const maxSize = Math.max(...iconSizeOptions);

    it('fails with size outside options', () => {
      expect(validateSize(maxSize + 10)).toBe(false);
    });

    it('passes with size in options', () => {
      expect(validateSize(maxSize)).toBe(true);
    });
  });

  describe('name validator', () => {
    it('fails with name that does not exist', () => {
      const badName = `${TEST_NAME}-bogus-zebra`;
      consoleSpy = jest.spyOn(console, 'warn').mockImplementation();

      expect(validateName(badName)).toBe(false);

      expect(consoleSpy).toHaveBeenCalledWith(
        `Icon '${badName}' is not a known icon of @gitlab/svgs`,
      );
    });

    it('passes with name that exists', () => {
      expect(validateName(TEST_NAME)).toBe(true);
    });
  });
});
