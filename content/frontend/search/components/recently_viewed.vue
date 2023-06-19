<script>
import { GlLink } from '@gitlab/ui';
import { getCookie } from '../recently_viewed';

export default {
  components: {
    GlLink,
  },
  data() {
    return {
      pageHistory: [],
    };
  },
  created() {
    this.pageHistory = JSON.parse(getCookie('pageHistory')) || [];
    this.pageHistory.shift(); // Drop the current page
    // Pass the list length to the parent component for keyboard nav.
    this.$emit('pageHistoryInit', this.pageHistory.length);
  },
};
</script>

<template>
  <div v-if="pageHistory.length" class="gl-py-3 gl-mt-3">
    <div class="gl-font-weight-bold gl-text-left">Recently viewed</div>
    <ul class="gl-pl-0 gl-mb-3 gl-pt-3">
      <li v-for="(page, index) in pageHistory" :key="page.path" class="gl-list-style-none">
        <gl-link
          :href="page.path"
          :data-link-index="index"
          class="gl-text-gray-700 gl-py-3 gl-px-2 gl-display-block gl-text-left"
        >
          {{ page.title }}
        </gl-link>
      </li>
    </ul>
  </div>
</template>
