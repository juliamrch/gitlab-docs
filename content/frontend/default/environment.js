/**
 * Utilities for determining site environment.
 */

export const GlHosts = [
  {
    environment: 'production',
    host: 'docs.gitlab.com',
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
