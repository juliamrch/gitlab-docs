/**
 * Creates a mock browser window object with a given path.
 * @param {String} pathname
 */
export const setWindowPath = (pathname) => {
  const location = {
    ...window.location,
    pathname,
  };
  Object.defineProperty(window, 'location', {
    writable: true,
    value: location,
  });
};

/**
 * Creates a mock gitlab-docs-version metatag.
 * @param {String} pathname
 */
export const setVersionMetatag = (version) => {
  const meta = document.createElement('meta');
  meta.setAttribute('name', 'gitlab-docs-version');
  meta.setAttribute('content', version);
  document.head.appendChild(meta);
};
