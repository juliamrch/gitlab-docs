import { getArchivesVersions } from '../services/fetch_versions';

const ARCHIVES_SITE_URL = 'https://archives.docs.gitlab.com';

document.addEventListener('DOMContentLoaded', async () => {
  const archiveVersions = await getArchivesVersions();

  /**
   * Split the request path by slashes into an array,
   * filter out empty values, and note the first element.
   * This value may match a valid version we host on the archives site.
   */
  const requestVersion = window.location.pathname.split('/').filter((n) => n)[0];

  // If this is a version on the archives site, redirect.
  if (archiveVersions.includes(requestVersion)) {
    window.location.href = `${ARCHIVES_SITE_URL}${window.location.pathname}`;
  }
});
