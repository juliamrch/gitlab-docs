/**
 * @jest-environment jsdom
 */

import { shallowMount } from '@vue/test-utils';
import flushPromises from 'flush-promises';
import VersionsMenu from '../../../../content/frontend/default/components/versions_menu.vue';
import * as fetchVersions from '../../../../content/frontend/services/fetch_versions';
import * as environment from '../../../../content/frontend/default/environment';
import { mockVersions, mockArchiveVersions } from '../../__mocks__/versions_mock';
import { setWindowPath, setVersionMetatag } from './helpers/versions_helper';

describe('component: Versions menu', () => {
  const archivesUrl = 'https://archives.docs.gitlab.com';

  beforeEach(() => {
    jest.clearAllMocks();
    jest.spyOn(fetchVersions, 'getVersions').mockReturnValue(mockVersions);
    jest.spyOn(fetchVersions, 'getArchivesVersions').mockReturnValue(mockArchiveVersions);
    jest.spyOn(environment, 'isProduction').mockReturnValue(true);
  });
  afterEach(() => {
    document.querySelector('meta[name="gitlab-docs-version"]').remove();
  });

  it('Fetches versions.json and displays current version', async () => {
    const wrapper = shallowMount(VersionsMenu);
    setVersionMetatag(mockVersions.next);
    await flushPromises();

    expect(fetchVersions.getVersions).toHaveBeenCalledTimes(1);
    expect(fetchVersions.getArchivesVersions).toHaveBeenCalledTimes(1);

    const nextVersion = wrapper.find('[data-testid="next-version"]').text();
    expect(nextVersion).toEqual(mockVersions.next);
  });

  it('Generates correct menu links from the homepage', async () => {
    setWindowPath('/');
    setVersionMetatag(mockVersions.next);
    const wrapper = shallowMount(VersionsMenu);
    await wrapper.setData({ activeVersion: mockVersions.next, versions: mockVersions });

    expect(wrapper.vm.getVersionPath('')).toBe('/');
    expect(wrapper.vm.getVersionPath(mockVersions.current)).toBe(`/${mockVersions.current}/`);

    mockVersions.last_minor.forEach((v) => {
      expect(wrapper.vm.getVersionPath(v)).toBe(`/${v}/`);
    });
    mockVersions.last_major.forEach((v) => {
      expect(wrapper.vm.getVersionPath(v)).toBe(`${archivesUrl}/${v}/`);
    });
  });

  it('Generates correct menu links from an interior page', async () => {
    setWindowPath('/ee/user/project/issue_board.html');
    setVersionMetatag(mockVersions.next);

    const wrapper = shallowMount(VersionsMenu);
    await wrapper.setData({ activeVersion: mockVersions.next, versions: mockVersions });

    expect(wrapper.vm.getVersionPath('')).toBe('/ee/user/project/issue_board.html');
    expect(wrapper.vm.getVersionPath(mockVersions.current)).toBe(
      `/${mockVersions.current}/ee/user/project/issue_board.html`,
    );

    mockVersions.last_minor.forEach((v) => {
      expect(wrapper.vm.getVersionPath(v)).toBe(`/${v}/ee/user/project/issue_board.html`);
    });
    mockVersions.last_major.forEach((v) => {
      expect(wrapper.vm.getVersionPath(v)).toBe(
        `${archivesUrl}/${v}/ee/user/project/issue_board.html`,
      );
    });
  });

  it('Generates correct menu links from an older version on docs.gitlab.com', async () => {
    setWindowPath('/15.2/runner');
    setVersionMetatag('15.2');

    const wrapper = shallowMount(VersionsMenu);
    await wrapper.setData({ versions: mockVersions, archiveVersions: mockArchiveVersions });

    expect(wrapper.vm.getVersionPath('')).toBe('/runner');
    expect(wrapper.vm.getVersionPath(mockVersions.current)).toBe(`/${mockVersions.current}/runner`);

    mockVersions.last_minor.forEach((v) => {
      expect(wrapper.vm.getVersionPath(v)).toBe(`/${v}/runner`);
    });
    mockVersions.last_major.forEach((v) => {
      expect(wrapper.vm.getVersionPath(v)).toBe(`${archivesUrl}/${v}/runner`);
    });
  });

  it('Shows simplified menu on non-production sites', async () => {
    jest.spyOn(environment, 'isProduction').mockReturnValue(false);
    setVersionMetatag('14.10');
    const wrapper = shallowMount(VersionsMenu);
    expect(wrapper.find('[data-testid="versions-menu"] a:nth-child(2)').exists()).toBe(false);
  });
});

describe('isOnlineArchivedVersion', () => {
  beforeEach(() => {
    global.fetch = jest.fn(() =>
      Promise.resolve({
        json: () => Promise.resolve([mockVersions]),
      }),
    );
  });

  it('Returns the correct value for the pre-release version', async () => {
    const result = await fetchVersions.isOnlineArchivedVersion('15.3');
    expect(result).toBe(false);
  });

  it('Returns the correct value for the current stable version', async () => {
    const result = await fetchVersions.isOnlineArchivedVersion('15.2');
    expect(result).toBe(false);
  });

  it('Returns the correct values for previous minor and major releases', async () => {
    const olderVersions = [...mockVersions.last_minor, mockVersions.last_minor];
    olderVersions.forEach(async (v) => {
      const result = await fetchVersions.isOnlineArchivedVersion(v);
      expect(result).toBe(true);
    });
  });
});
