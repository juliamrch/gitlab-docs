/**
 * Find the first child of the given element with the given tag name
 *
 * @param {Element} el
 * @param {String} tagName
 * @returns {Element | null} Returns first child that matches the given tagName (or null if not found)
 */
export const findChildByTagName = (el, tagName) =>
  Array.from(el.childNodes).find((x) => x.tagName === tagName.toUpperCase());

/**
 * Get HTML between two elements.
 *
 * @param {Element} el
 * @param {String} selector
 * @returns {String} HTML between the two given elements
 *
 * @see https://gomakethings.com/how-to-get-all-siblings-of-an-element-until-a-selector-is-found-with-vanilla-js/
 */
export const getNextUntil = (el, selector) => {
  const siblings = [];
  let next = el.nextElementSibling;

  while (next) {
    if (selector && next.matches(selector)) break;
    siblings.push(next.outerHTML);
    next = next.nextElementSibling;
  }

  return siblings.join('');
};

/**
 * Check if an element is contained within a heading.
 *
 * @param {Element} el
 * @returns {Boolean}
 */
export const isContainedInHeading = (el) => {
  // Loop upwards in the DOM through all parent elements, checking for headers.
  for (let parent = el.parentNode; parent !== null; parent = parent.parentNode) {
    if (parent.tagName && /^H\d$/.test(parent.tagName)) {
      return true;
    }
  }
  return false;
};
