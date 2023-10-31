<script>
import { GlLink } from '@gitlab/ui';
import { getCookie } from '../../shared/cookies';

export default {
  components: {
    GlLink,
  },
  data() {
    return {
      pageHistory: [],
      popularItems: [{ title: 'CI/CD YAML syntax reference', path: '/ee/ci/yaml/' }],
    };
  },
  created() {
    this.pageHistory = JSON.parse(getCookie('pageHistory')) || [];
    this.pageHistory.shift(); // Drop the current page

    // Pass the list lengths to the parent component for keyboard nav,
    this.$emit('pageHistoryInit', this.pageHistory.length + this.popularItems.length);
  },
  methods: {
    /**
     * Calculate the keyboard nav index for "Popular" items.
     * Because "Recently viewed" can contain a variable number of items,
     * this needs to be derived from the length of that list.
     */
    kbdNavIndex(index) {
      return this.pageHistory.length + index;
    },
  },
};
</script>

<template>
  <div class="gl-py-3 gl-mt-3">
    <template v-if="pageHistory.length">
      <div class="gl-font-weight-bold gl-text-left">Recently viewed</div>
      <ul class="gl-pl-0 gl-mb-3 gl-pt-3">
        <li v-for="(page, index) in pageHistory" :key="page.path" class="gl-list-style-none">
          <gl-link
            :href="page.path"
            :data-link-index="index"
            data-result-type="history"
            class="gl-text-gray-700 gl-py-3 gl-px-2 gl-display-block gl-text-left"
          >
            {{ page.title }}
          </gl-link>
        </li>
      </ul>
    </template>

    <div class="gl-font-weight-bold gl-text-left">Popular</div>
    <ul class="gl-pl-0 gl-mb-3 gl-pt-3">
      <li v-for="(page, index) in popularItems" :key="page.path" class="gl-list-style-none">
        <gl-link
          :href="page.path"
          :data-link-index="kbdNavIndex(index)"
          data-result-type="popular"
          class="gl-text-gray-700 gl-py-3 gl-px-2 gl-display-block gl-text-left"
        >
          {{ page.title }}
        </gl-link>
      </li>
    </ul>
  </div>
</template>
