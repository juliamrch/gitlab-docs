/* eslint-disable no-console */

import { satisfies, compareVersions } from 'compare-versions';

const DOCS_VERSIONS_ENDPOINT = 'https://docs.gitlab.com/versions.json';
const ARCHIVE_VERSIONS_ENDPOINT = 'https://archives.docs.gitlab.com/archive_versions.json';

// Archived versions moved registries starting with 15.5.
const DOCS_IMAGES_ENDPOINT_V1 =
  'https://gitlab.com/api/v4/projects/1794617/registry/repositories/631635/tags?per_page=100';
const DOCS_IMAGES_ENDPOINT_V2 =
  'https://gitlab.com/api/v4/projects/1794617/registry/repositories/3631228/tags?per_page=100';

export const SITE_VERSION = document
  .querySelector('meta[name="gitlab-docs-version"]')
  ?.getAttribute('content');

/**
 * Fetch a list of versions available on docs.gitlab.com.
 *
 * @returns Array
 */
let cachedVersions = null;

export async function getVersions() {
  if (!cachedVersions) {
    try {
      const data = await (await fetch(DOCS_VERSIONS_ENDPOINT)).json();
      cachedVersions = Object.assign(...data);
    } catch (error) {
      console.error(error);
    }
  }
  return cachedVersions || [];
}

/**
 * Fetch a list of archived versions available as container images.
 *
 * The Archive image endpoint changed in 15.5, so we need to query
 * two separate endpoints and combine the result to build our list.
 *
 * @returns Array
 */
const fetchArchiveImages = async (endpoint, versionRange) => {
  try {
    const response = await fetch(endpoint);
    const data = await response.json();
    return data.filter(
      (object) => !Number.isNaN(Number(object.name)) && satisfies(object.name, versionRange),
    );
  } catch (error) {
    console.error(error);
    return [];
  }
};
export async function getArchiveImages() {
  const images = await fetchArchiveImages(DOCS_IMAGES_ENDPOINT_V1, '<15.6');
  const newerImages = await fetchArchiveImages(DOCS_IMAGES_ENDPOINT_V2, '>=15.6');
  return (
    [...images, ...newerImages].sort((a, b) => compareVersions(a.name, b.name)).reverse() || []
  );
}

/**
 * Fetch a list of site versions available on the Archives site.
 *
 * @returns Array
 */
export async function getArchivesVersions() {
  const versions = await fetch(ARCHIVE_VERSIONS_ENDPOINT)
    .then((response) => response.json())
    .catch((error) => console.error(error));
  return versions || [];
}

/**
 * Check if a version of the site is archived.
 *
 * All versions except the pre-release and most
 * recent stable version are considered archived
 * versions.
 *
 * Note that this will return false in an offline
 * or air-gapped environment.
 *
 * @returns Boolean
 */
export async function isOnlineArchivedVersion(version) {
  const onlineVersions = await getVersions();
  if (Object.keys(onlineVersions).length > 0) {
    return ![onlineVersions.next, onlineVersions.current].includes(version);
  }
  return false;
}
