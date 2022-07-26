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
