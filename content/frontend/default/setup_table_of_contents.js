import Vue from 'vue';
import { parseTOC } from '../shared/toc/parse_toc';
import TableOfContents from './components/table_of_contents.vue';
import { StickToFooter } from './directives/stick_to_footer';

const SIDEBAR_SELECTOR = '.doc-nav';
const MARKDOWN_TOC_ID = 'markdown-toc';
const MAIN_SELECTOR = '.js-main-wrapper';

export const setupTableOfContents = () => {
  const sidebar = document.querySelectorAll(SIDEBAR_SELECTOR);
  const menu = document.getElementById(MARKDOWN_TOC_ID);
  const main = document.querySelector(MAIN_SELECTOR);

  if (!sidebar || !menu) {
    return null;
  }

  if (main) {
    main.classList.add('has-toc');
  }

  const items = parseTOC(menu);
  menu.remove();

  const el = document.createElement('div');
  return sidebar.forEach((sidebarEl) => {
    sidebarEl.appendChild(el);
    return new Vue({
      el,
      directives: {
        StickToFooter,
      },
      render(h) {
        return h(TableOfContents, {
          props: {
            items,
          },
          directives: [
            {
              name: 'stick-to-footer',
              value: MAIN_SELECTOR,
              expression: MAIN_SELECTOR,
            },
          ],
        });
      },
    });
  });
};
