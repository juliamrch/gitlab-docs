/**
 * @jest-environment jsdom
 */

import { mount } from '@vue/test-utils';
import SearchPage from '../../../content/frontend/search/components/search_page.vue';

const propsData = { docsVersion: 'main' };
const searchFormSelector = '[data-testid="docs-search"]';

describe('component: Search page', () => {
  it('Search form renders', () => {
    const wrapper = mount(SearchPage, {
      propsData,
      stubs: {
        'ais-instant-search': true,
        'ais-search-box': true,
        'ais-state-results': true,
        'ais-configure': true,
      },
    });
    expect(wrapper.find(searchFormSelector).isVisible()).toBe(true);
  });
});
