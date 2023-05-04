/**
 * This script is copied from gitlab-ui:
 * https://gitlab.com/gitlab-org/gitlab-ui/-/blob/main/tests/clean_html_element_serializer.js
 */

// slot-scope attribute is a result of Vue.js 3 stubs being serialized in slot context, drop it
const ATTRIBUTES_TO_REMOVE = ['slot-scope'];
// Taken from https://github.com/vuejs/vue/blob/72aed6a149b94b5b929fb47370a7a6d4cb7491c5/src/platforms/web/util/attrs.ts#L37-L44
const BOOLEAN_ATTRIBUTES = new Set(
  (
    'allowfullscreen,async,autofocus,autoplay,checked,compact,controls,declare,' +
    'default,defaultchecked,defaultmuted,defaultselected,defer,disabled,' +
    'enabled,formnovalidate,hidden,indeterminate,inert,ismap,itemscope,loop,multiple,' +
    'muted,nohref,noresize,noshade,novalidate,nowrap,open,pauseonexit,readonly,' +
    'required,reversed,scoped,seamless,selected,sortable,' +
    'truespeed,typemustmatch,visible'
  ).split(','),
);

const visited = new WeakSet();

// Lovingly borrowed from https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model/Whitespace#whitespace_helper_functions
function isAllWhitespace(node) {
  return !/[^\t\n\r ]/.test(node.textContent);
}

function isIgnorable(node) {
  return (
    node.nodeType === Node.COMMENT_NODE || // A comment node
    (node.nodeType === Node.TEXT_NODE && isAllWhitespace(node))
  ); // a text node, all ws
}

export function test(received) {
  return received instanceof Element && !visited.has(received);
}

export function serialize(received, config, indentation, depth, refs, printer) {
  const clone = received.cloneNode(true);
  visited.add(clone);

  // Remove comment nodes
  const iterator = document.createNodeIterator(
    clone,
    // eslint-disable-next-line no-bitwise
    NodeFilter.SHOW_COMMENT | NodeFilter.SHOW_TEXT | NodeFilter.SHOW_ELEMENT,
  );
  const ignorableNodes = [];

  for (let currentNode = iterator.nextNode(); currentNode; currentNode = iterator.nextNode()) {
    if (isIgnorable(currentNode)) {
      ignorableNodes.push(currentNode);
    } else {
      if (currentNode instanceof Element && !currentNode.tagName.includes('-')) {
        ATTRIBUTES_TO_REMOVE.forEach((attr) => currentNode.removeAttribute(attr));
        BOOLEAN_ATTRIBUTES.forEach((attr) => {
          if (currentNode.hasAttribute(attr) && currentNode.getAttribute(attr) === attr) {
            currentNode.setAttribute(attr, '');
          }
        });
      }
      visited.add(currentNode);
    }
  }

  ignorableNodes.forEach((x) => x.remove());

  return printer(clone, config, indentation, depth, refs);
}
