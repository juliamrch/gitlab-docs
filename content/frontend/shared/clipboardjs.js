/* global $ */

import { spriteIcon } from './sprite_icon';

const createCopyButton = () => {
  const button = document.createElement('button');
  button.className = 'clip-btn';
  button.title = 'Click to copy';
  button.dataset.selector = 'true';
  button.innerHTML = spriteIcon('copy-to-clipboard', 'gl-icon ml-1 mr-1 s16');
  return button;
};

window.addEventListener('load', () => {
  document.querySelectorAll('pre').forEach((element) => {
    const button = createCopyButton();
    element.appendChild(button);
  });

  $('button').tooltip({
    trigger: 'click',
    placement: 'left',
  });

  function setTooltip(btn, message) {
    $(btn).tooltip('hide').attr('data-original-title', message).tooltip('show');
  }

  function hideTooltip(btn) {
    setTimeout(function hide() {
      $(btn).tooltip('hide');
    }, 1000);
  }

  document.querySelectorAll('.clip-btn').forEach((button) => {
    button.addEventListener('click', (event) => {
      const clickedButton = event.target;

      try {
        navigator.clipboard.writeText(clickedButton.previousElementSibling.innerText);
        setTooltip(clickedButton, 'Copied!');
        hideTooltip(clickedButton);
      } catch {
        setTooltip(clickedButton, 'Failed!');
        hideTooltip(clickedButton);
      }
    });
  });
});
