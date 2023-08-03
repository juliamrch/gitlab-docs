<script>
import { GlIcon, GlCollapse } from '@gitlab/ui';
import { flattenItems } from '../../shared/toc/flatten_items';
import TableOfContentsList from './table_of_contents_list.vue';

export default {
  name: 'TableOfContents',
  components: {
    GlCollapse,
    GlIcon,
    TableOfContentsList,
  },
  props: {
    items: {
      type: Array,
      required: true,
    },
    initialCollapsed: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      isCollapsed: this.initialCollapsed,
    };
  },
  computed: {
    allItems() {
      // Flatten the items so that only one is highlighted at a time
      return flattenItems(this.items);
    },
    collapseIcon() {
      return this.isCollapsed ? 'chevron-right' : 'chevron-down';
    },
  },
  methods: {
    toggleCollapse() {
      this.isCollapsed = !this.isCollapsed;
    },
  },
};
</script>
<template>
  <div class="markdown-toc table-of-contents-container gl-lg-sticky">
    <div class="table-of-contents">
      <h4 class="gl-my-0! border-0 toc-sm d-xl-none">
        <a
          class="text-decoration-none border-bottom-0"
          href="#"
          role="button"
          :aria-expanded="!isCollapsed"
          aria-controls="markdown-toc"
          data-testid="collapse"
          @click.prevent="toggleCollapse"
        >
          <gl-icon :name="collapseIcon" />On this page</a
        >
      </h4>
      <h4 class="border-0 gl-font-base font-weight-bold toc-lg">On this page</h4>
      <gl-collapse ref="container" :visible="!isCollapsed" data-testid="container">
        <table-of-contents-list :items="allItems" class="my-0" data-testid="main-list" />
      </gl-collapse>
    </div>
  </div>
</template>
