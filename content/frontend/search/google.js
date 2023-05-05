import Vue from 'vue';
import GoogleResults from './components/google_results.vue';
import GoogleSearchForm from './components/google_search_form.vue';
import SearchForm from './components/search_form.vue';

const mountVue = (el, Component, Properties = {}) => {
  return new Vue({
    el,
    components: { Component },
    render(createElement) {
      return createElement(Component, Properties);
    },
  });
};

document.addEventListener('DOMContentLoaded', () => {
  const isHomepage = ['/', '/index.html'].includes(window.location.pathname);

  mountVue('.js-google-search', GoogleResults);
  mountVue('.js-google-search-form', GoogleSearchForm, {
    props: {
      borderless: !isHomepage,
    },
  });

  // Lunr.js
  mountVue('.js-search-form', SearchForm);
});

// Keyboard shortcut: forward slash focuses on search forms
document.addEventListener('keyup', (e) => {
  if (e.key !== '/' || e.ctrlKey || e.metaKey) return;
  if (/^(?:input|textarea|select|button)$/i.test(e.target.tagName)) return;
  e.preventDefault();
  document.querySelector('input[type="search"]').focus();
});
