/**
 * @jest-environment jsdom
 */

import { mount } from '@vue/test-utils';
import flushPromises from 'flush-promises';
import VersionsMenu from '../../../../content/frontend/default/components/versions_menu.vue';
import { getVersions } from '../../../../content/frontend/services/fetch_versions';

jest.mock('../../../../content/frontend/services/fetch_versions');
beforeEach(() => {
  jest.clearAllMocks();
});

describe('component: Versions menu', () => {
  it('Fetches versions.json and displays current version', async () => {
    const mockNextVersion = '15.2';
    getVersions.mockResolvedValueOnce({ next: mockNextVersion });
    const wrapper = mount(VersionsMenu);

    await flushPromises();
    expect(getVersions).toHaveBeenCalledTimes(1);

    const nextVersion = wrapper.find('[data-testid="next-version"]').element.textContent;
    expect(nextVersion).toEqual(mockNextVersion);
  });
});
