/* eslint-disable no-console */

const DOCS_VERSIONS_ENDPOINT = 'https://docs.gitlab.com/versions.json';
const DOCS_IMAGES_ENDPOINT =
  'https://gitlab.com/api/v4/projects/1794617/registry/repositories/631635/tags?per_page=100';

export function getVersions() {
  return fetch(DOCS_VERSIONS_ENDPOINT)
    .then((response) => response.json())
    .then((data) => {
      return Object.assign(...data);
    })
    .catch((error) => console.error(error));
}

export function getArchiveImages() {
  return fetch(DOCS_IMAGES_ENDPOINT)
    .then((response) => response.json())
    .then((data) => {
      // We only want tags for versioned releases, so drop any that aren't integers.
      return data.filter((object) => !Number.isNaN(Number(object.name))).reverse();
    })
    .catch((error) => console.error(error));
}
