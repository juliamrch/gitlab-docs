/**
 * @jest-environment jsdom
 */

import { shallowMount } from '@vue/test-utils';
import ArchivesPage from '../../../../content/frontend/default/components/archives_page.vue';
import { getVersions } from '../../../../content/frontend/services/fetch_versions';
import { getArchiveImages } from '../../../../content/frontend/services/fetch_archive_images';
import { mockVersions, mockArchiveImages } from '../../__mocks__/versions_mock';

jest.mock('../../../../content/frontend/services/fetch_versions');
jest.mock('../../../../content/frontend/services/fetch_archive_images');

beforeEach(() => {
  jest.clearAllMocks();
  getVersions.mockResolvedValueOnce(mockVersions);
  getArchiveImages.mockResolvedValueOnce(mockArchiveImages);
});

describe('content/frontend/default/components/archives_page.vue', () => {
  it('Shows correct online versions', async () => {
    const wrapper = shallowMount(ArchivesPage);
    await wrapper.setData({
      onlineVersions: [...mockVersions.last_minor, ...mockVersions.last_major],
    });

    expect(wrapper.find('[data-testid="online-version-15.1"]').exists()).toBe(true);
    expect(wrapper.find('[data-testid="online-version-15.3"]').exists()).toBe(false);
  });

  it('Shows correct offline versions', async () => {
    const wrapper = shallowMount(ArchivesPage);
    await wrapper.setData({ offlineVersions: mockArchiveImages });

    expect(wrapper.find('[data-testid="offline-version-14.9"]').exists()).toBe(true);
    expect(wrapper.find('[data-testid="online-version-15.3"]').exists()).toBe(false);
  });
});
