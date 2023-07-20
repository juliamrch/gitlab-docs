/* global $ */

import { spriteIcon } from './sprite_icon';

// Add a copy button to every fenced code block
$('pre').append(
  $(
    `<button class="clip-btn" title="Click to copy" data-selector="true">${spriteIcon(
      'copy-to-clipboard',
      'gl-icon ml-1 mr-1 s16',
    )}</button>`,
  ),
);

// Tooltip
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

$('.clip-btn').on('click', function onCopyClick() {
  try {
    navigator.clipboard.writeText(this.previousElementSibling.innerText);

    setTooltip(this, 'Copied!');
    hideTooltip(this);
  } catch {
    setTooltip(this, 'Failed!');
    hideTooltip(this);
  }
});
