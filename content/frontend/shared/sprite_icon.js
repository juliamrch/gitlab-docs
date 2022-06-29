/**
 * Sprite helper adapted from
 * https://gitlab.com/gitlab-org/gitlab/-/blob/master/app/assets/javascripts/lib/utils/common_utils.js#L472
 */

export const spriteIcon = (icon, className = '') => {
  const spritePath = '/assets/images/icons.svg';
  const classAttribute = className.length > 0 ? `class="${className}"` : '';

  return `<svg ${classAttribute}><use xlink:href="${spritePath}#${icon}" /></svg>`;
};
