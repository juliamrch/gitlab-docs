/* eslint-disable no-console */

const DOCS_VERSIONS_ENDPOINT = 'https://docs.gitlab.com/versions.json';
const GITLAB_RELEASE_DATES_ENDPOINT = 'https://docs.gitlab.com/release_dates.json';
const DOCS_IMAGES_ENDPOINT =
  'https://gitlab.com/api/v4/projects/1794617/registry/repositories/631635/tags?per_page=100';
const ARCHIVE_VERSIONS_ENDPOINT = 'https://archives.docs.gitlab.com/archive_versions.json';

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
 * @returns Array
 */
export async function getArchiveImages() {
  const images = await fetch(DOCS_IMAGES_ENDPOINT)
    .then((response) => response.json())
    .then((data) => {
      // We only want tags for versioned releases, so drop any that aren't numeric.
      return data.filter((object) => !Number.isNaN(Number(object.name))).reverse();
    })
    .catch((error) => console.error(error));
  return images || [];
}

/**
 * Fetch a list of versions available on the Archives site.
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
