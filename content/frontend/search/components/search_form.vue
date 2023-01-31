<script>
import { GlSearchBoxByClick } from '@gitlab/ui';

export default {
  components: {
    GlSearchBoxByClick,
  },
  data() {
    return {
      query: '',
    };
  },
  methods: {
    onSubmit() {
      window.location.href = `/search/?query=${encodeURI(this.query)}`;
    },
  },
};
</script>

<template>
  <gl-search-box-by-click v-model="query" class="search-form" @submit="onSubmit" />
</template>
