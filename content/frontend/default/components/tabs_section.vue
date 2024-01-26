<script>
import {
  GlAccordion,
  GlAccordionItem,
  GlTabs,
  GlTab,
  GlSafeHtmlDirective as SafeHtml,
} from '@gitlab/ui';

/**
 * If the window is greater than or equal to this width (in px),
 * the component will render as Tabs.
 * For smaller windows, it will render as Accordions.
 * If the responsive property is false, this has no effect.
 */
const TABS_BREAKPOINT = 990;

export default {
  components: {
    GlTabs,
    GlTab,
    GlAccordion,
    GlAccordionItem,
  },
  directives: {
    SafeHtml,
  },
  props: {
    tabTitles: {
      type: Array,
      required: true,
    },
    tabContents: {
      type: Array,
      required: true,
    },
    responsive: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      // Allows GitLab SVGs to render through v-safe-html
      // https://gitlab.com/groups/gitlab-org/-/epics/4273#svgs
      safe_html_config: { ADD_TAGS: ['use'] },
      isWideScreen: window.innerWidth >= TABS_BREAKPOINT,
    };
  },
  computed: {
    isTabs() {
      return this.isWideScreen || !this.responsive;
    },
    hasValidContent() {
      // Check if the number of tab titles equals the number of tab content sections
      return this.tabTitles.filter(Boolean).length === this.tabContents.filter(Boolean).length;
    },
  },
  mounted() {
    if (this.responsive) {
      window.addEventListener('resize', this.handleResize);
    }
  },
  beforeDestroy() {
    if (this.responsive) {
      window.removeEventListener('resize', this.handleResize);
    }
  },
  methods: {
    handleResize() {
      this.isWideScreen = window.innerWidth >= TABS_BREAKPOINT;
    },
  },
};
</script>

<template>
  <div>
    <gl-tabs
      v-if="isTabs && hasValidContent"
      :sync-active-tab-with-query-params="true"
      class="gl-border-b gl-mb-5"
    >
      <gl-tab
        v-for="(title, key) in tabTitles"
        :key="key"
        v-safe-html:[safe_html_config]="tabContents[key]"
        :title="title"
        :query-param-value="title"
      />
    </gl-tabs>

    <gl-accordion
      v-else-if="hasValidContent"
      :auto-collapse="false"
      :header-level="2"
      class="gl-my-5"
    >
      <gl-accordion-item v-for="(title, key) in tabTitles" :key="key" :title="title">
        <div v-safe-html:[safe_html_config]="tabContents[key]"></div>
      </gl-accordion-item>
    </gl-accordion>
  </div>
</template>
