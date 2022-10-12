export function getArchiveImages() {
  return fetch(
    'https://gitlab.com/api/v4/projects/1794617/registry/repositories/631635/tags?per_page=100',
  )
    .then((response) => response.json())
    .then((data) => {
      // We only want tags for versioned releases, so drop any that aren't integers.
      const tags = data.filter((object) => {
        return !Number.isNaN(Number(object.name));
      });
      return tags.reverse();
    })
    .catch((error) => console.error(error)); // eslint-disable-line no-console
}
