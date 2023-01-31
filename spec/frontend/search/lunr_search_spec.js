/**
 * @jest-environment jsdom
 */

import { shallowMount } from '@vue/test-utils';
import SearchPage from '../../../content/frontend/search/components/lunr_results.vue';

describe('content/frontend/search/components/lunr_results.vue', () => {
  it('Search form renders', () => {
    const wrapper = shallowMount(SearchPage);
    expect(wrapper.findComponent(SearchPage).isVisible()).toBe(true);
  });

  it('Index fetch failure shows an error', async () => {
    const wrapper = shallowMount(SearchPage);
    const fetch = jest.fn(() => {
      throw new Error('error');
    });

    try {
      await fetch('/assets/javascripts/lunr-index.json');
    } catch (e) {
      expect(wrapper.find('[data-testid="lunr-error"]').isVisible()).toBe(true);
    }
  });
});
