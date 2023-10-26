/**
 * @jest-environment jsdom
 */

import { shallowMount } from '@vue/test-utils';
import SearchPage from '../../../content/frontend/search/components/lunr_results.vue';
import { setVersionMetatag } from '../default/components/helpers/versions_helper';

describe('content/frontend/search/components/lunr_results.vue', () => {
  const mockVersion = '16.2';
  beforeEach(() => {
    setVersionMetatag(mockVersion);
  });

  it('Page title includes the site version', () => {
    const wrapper = shallowMount(SearchPage);
    const version = wrapper.find('[data-testid="version-header"]').text();
    expect(version).toContain(mockVersion);
  });

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
