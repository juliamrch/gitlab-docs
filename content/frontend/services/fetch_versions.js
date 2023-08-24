/* eslint-disable no-console */

import { satisfies, compareVersions } from 'compare-versions';

const DOCS_VERSIONS_ENDPOINT = 'https://docs.gitlab.com/versions.json';
const GITLAB_RELEASE_DATES_ENDPOINT = 'https://docs.gitlab.com/release_dates.json';
const ARCHIVE_VERSIONS_ENDPOINT = 'https://archives.docs.gitlab.com/archive_versions.json';

// Archived versions moved registries starting with 15.5.
const DOCS_IMAGES_ENDPOINT_V1 =
  'https://gitlab.com/api/v4/projects/1794617/registry/repositories/631635/tags?per_page=100';
const DOCS_IMAGES_ENDPOINT_V2 =
  'https://gitlab.com/api/v4/projects/1794617/registry/repositories/3631228/tags?per_page=100';

/**
 * Fetch a list of versions available on docs.gitlab.com.
 *
 * @returns Array
 */
export async function getVersions() {
  const versions = await fetch(DOCS_VERSIONS_ENDPOINT)
    .then((response) => response.json())
    .then((data) => {
      return Object.assign(...data);
    })
    .catch((error) => console.error(error));
  return versions || [];
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
  const images = await fetchArchiveImages(DOCS_IMAGES_ENDPOINT_V1, '<15.5');
  const newerImages = await fetchArchiveImages(DOCS_IMAGES_ENDPOINT_V2, '>=15.5');
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
 * Fetch a list of versions with their associated release dates.
 *
 * @returns Array
 */
export async function getReleaseDates() {
  const releaseDates = await fetch(GITLAB_RELEASE_DATES_ENDPOINT)
    .then((response) => response.json())
    .then((data) => {
      return Object.assign(...data);
    })
    .catch((error) => console.error(error));
  return releaseDates || [];
}
