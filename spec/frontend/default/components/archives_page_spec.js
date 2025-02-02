/**
 * @jest-environment jsdom
 */

import { shallowMount } from '@vue/test-utils';
import ArchivesPage from '../../../../content/frontend/archives/archives_page.vue';
import {
  getVersions,
  getArchiveImages,
} from '../../../../content/frontend/services/fetch_versions';
import { mockVersions, mockArchiveImages } from '../../__mocks__/versions_mock';

jest.mock('../../../../content/frontend/services/fetch_versions');

beforeEach(() => {
  jest.clearAllMocks();
  getVersions.mockResolvedValueOnce(mockVersions);
  getArchiveImages.mockResolvedValueOnce(mockArchiveImages);
});

describe('content/frontend/default/components/archives_page.vue', () => {
  it('Shows correct latest stable', async () => {
    const wrapper = shallowMount(ArchivesPage);
    await wrapper.setData({
      versions: mockVersions,
    });

    expect(wrapper.find('[data-testid="current-stable-15.2"]').exists()).toBe(true);
    expect(wrapper.find('[data-testid="current-stable-15.3"]').exists()).toBe(false);
  });

  it('Shows correct offline versions', async () => {
    const wrapper = shallowMount(ArchivesPage);
    await wrapper.setData({ archiveImages: mockArchiveImages });

    expect(wrapper.find('[data-testid="offline-version-14.9"]').exists()).toBe(true);
    expect(wrapper.find('[data-testid="offline-version-14.8"]').exists()).toBe(true);
    expect(wrapper.find('[data-testid="offline-version-15.3"]').exists()).toBe(false);
  });
});
