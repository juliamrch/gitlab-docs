/**
 * Utilities for determining site environment.
 */

export const GlHosts = [
  {
    environment: 'production',
    host: 'docs.gitlab.com',
  },
  {
    environment: 'archives',
    host: 'archives.docs.gitlab.com',
  },
  {
    environment: 'review',
    host: 'docs.gitlab-review.app',
  },
  {
    environment: 'local',
    host: 'localhost',
  },
];

export function isGitLabHosted() {
  return GlHosts.some((e) => window.location.host.includes(e.host));
}

export function isArchives() {
  return window.location.host === GlHosts.find((x) => x.environment === 'archives').host;
}
