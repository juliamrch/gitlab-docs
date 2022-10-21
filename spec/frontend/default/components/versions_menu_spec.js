/**
 * @jest-environment jsdom
 */

import { mount } from '@vue/test-utils';
import flushPromises from 'flush-promises';
import VersionsMenu from '../../../../content/frontend/default/components/versions_menu.vue';
import { getVersions } from '../../../../content/frontend/services/fetch_versions';
import { mockVersions } from '../../__mocks__/versions_mock';
import { setWindowPath } from './helpers/versions_menu_helper';

jest.mock('../../../../content/frontend/services/fetch_versions');

beforeEach(() => {
  jest.clearAllMocks();

  const meta = document.createElement('meta');
  meta.setAttribute('name', 'gitlab-docs-version');
  meta.setAttribute('content', '15.5');
  document.head.appendChild(meta);

  getVersions.mockResolvedValueOnce(mockVersions);
});

describe('component: Versions menu', () => {
  it('Fetches versions.json and displays current version', async () => {
    const wrapper = mount(VersionsMenu);
    await flushPromises();

    expect(getVersions).toHaveBeenCalledTimes(1);

    const nextVersion = wrapper.find('[data-testid="next-version"]').element.textContent;
    expect(nextVersion).toEqual(mockVersions.next);
  });

  it('Generates correct menu links from the homepage', async () => {
    setWindowPath('/');
    const wrapper = mount(VersionsMenu);

    expect(wrapper.vm.getVersionPath('')).toBe('/');
    expect(wrapper.vm.getVersionPath(mockVersions.current)).toBe(`/${mockVersions.current}/`);

    Object.values([...mockVersions.last_major, ...mockVersions.last_minor]).forEach(
      function testLink(v) {
        expect(wrapper.vm.getVersionPath(v)).toBe(`/${v}/`);
      },
    );
  });

  it('Generates correct menu links from an interior page', async () => {
    setWindowPath('/ee/user/project/issue_board.html');
    const wrapper = mount(VersionsMenu);
    await wrapper.setData({ activeVersion: '15.3', versions: mockVersions });

    expect(wrapper.vm.getVersionPath('')).toBe('/ee/user/project/issue_board.html');
    expect(wrapper.vm.getVersionPath(mockVersions.current)).toBe(
      `/${mockVersions.current}/ee/user/project/issue_board.html`,
    );

    Object.values([...mockVersions.last_major, ...mockVersions.last_minor]).forEach(
      function testLink(v) {
        expect(wrapper.vm.getVersionPath(v)).toBe(`/${v}/ee/user/project/issue_board.html`);
      },
    );
  });

  it('Generates correct menu links from an older version', async () => {
    setWindowPath('/14.10/runner');
    const wrapper = mount(VersionsMenu);
    await wrapper.setData({ activeVersion: '14.10', versions: mockVersions });

    expect(wrapper.vm.getVersionPath('')).toBe('/runner');
    expect(wrapper.vm.getVersionPath(mockVersions.current)).toBe(`/${mockVersions.current}/runner`);

    Object.values([...mockVersions.last_major, ...mockVersions.last_minor]).forEach(
      function testLink(v) {
        expect(wrapper.vm.getVersionPath(v)).toBe(`/${v}/runner`);
      },
    );
  });

  it('Shows simplified menu on non-production sites', async () => {
    const wrapper = mount(VersionsMenu);
    await wrapper.setData({ activeVersion: '14.10', versions: {} });
    expect(wrapper.find('[data-testid="versions-menu"] a:nth-child(2)').exists()).toBe(false);
  });
});
