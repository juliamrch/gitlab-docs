/* eslint-disable no-console */

import { compareVersions } from 'compare-versions';

const DOCS_VERSIONS_ENDPOINT = 'https://docs.gitlab.com/versions.json';
const DOCS_IMAGES_ENDPOINT =
  'https://gitlab.com/api/v4/projects/1794617/registry/repositories/631635/tags?per_page=100';

/**
 * Fetch a list of versions available on docs.gitlab.com.
 *
 * @returns Array
 */
export function getVersions() {
  return fetch(DOCS_VERSIONS_ENDPOINT)
    .then((response) => response.json())
    .then((data) => {
      return Object.assign(...data);
    })
    .catch((error) => console.error(error));
}

/**
 * Fetch a list of archived versions available as container images.
 *
 * @returns Array
 */
export function getArchiveImages() {
  return fetch(DOCS_IMAGES_ENDPOINT)
    .then((response) => response.json())
    .then((data) => {
      // We only want tags for versioned releases, so drop any that aren't integers.
      return data.filter((object) => !Number.isNaN(Number(object.name))).reverse();
    })
    .catch((error) => console.error(error));
}

/**
 * Fetch a list of versions available on the archives site.
 *
 * @returns Array
 */
export async function getArchivesVersions() {
  const onlineVersions = await getVersions();
  const archiveImages = await getArchiveImages();

  const oldestSupportedMinor = onlineVersions.last_major[1].split('.')[0];
  const oldestCurrentMinor = onlineVersions.last_minor[1];

  return archiveImages
    .map((object) => object.name)
    .filter(
      (v) =>
        compareVersions(v, oldestSupportedMinor) >= 0 && compareVersions(v, oldestCurrentMinor) < 0,
    );
}
