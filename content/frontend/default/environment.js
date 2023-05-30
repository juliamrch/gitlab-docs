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
  {
    environment: 'local',
    host: '127.0.0.1',
  },
];

export function isGitLabHosted() {
  return GlHosts.some((e) => window.location.hostname.includes(e.host));
}

export function isArchivesSite() {
  return window.location.hostname === GlHosts.find((x) => x.environment === 'archives').host;
}

export function isProduction() {
  return window.location.hostname === GlHosts.find((x) => x.environment === 'production').host;
}
