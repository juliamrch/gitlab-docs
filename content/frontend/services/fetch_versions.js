export function getVersions() {
  return fetch('https://docs.gitlab.com/versions.json')
    .then((response) => response.json())
    .then((data) => {
      return data[0];
    })
    .catch((error) => console.error(error)); // eslint-disable-line no-console
}
