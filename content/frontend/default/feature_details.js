/**
 * Formats the feature details box
 */

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.admonition-wrapper.details').forEach((detailsContent) => {
    // Add a line break before availability labels
    detailsContent.querySelectorAll('strong').forEach((label, index) => {
      if (index > 0) {
        label.insertAdjacentHTML('beforebegin', '<br>');
      }
    });

    // Add a bottom margin if we don't also have a History section
    if (!detailsContent.nextElementSibling.classList.contains('introduced-in')) {
      detailsContent.classList.add('gl-mb-5');
    }
  });
});
