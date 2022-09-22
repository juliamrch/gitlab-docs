<script>
/* global lunr */
import { GlSearchBoxByClick, GlLink } from '@gitlab/ui';

export default {
  components: {
    GlSearchBoxByClick,
    GlLink,
  },
  data() {
    return {
      query: '',
      submitted: false,
      error: false,
      results: [],
      contentMap: [],
      relevancy_threshold: 15,
    };
  },
  computed: {
    noResults() {
      return this.submitted && !this.results.length && !this.error;
    },
  },
  async created() {
    try {
      // Load the search index and content map.
      const [indexResp, mapResp] = await Promise.all([
        fetch('/assets/javascripts/lunr-index.json'),
        fetch('/assets/javascripts/lunr-map.json'),
      ]);
      const lindex = await indexResp.json();
      this.contentMap = await mapResp.json();

      // Initialize Lunr.
      const idx = lunr.Index.load(lindex);
      window.idx = idx;

      // If we have a query string in the URL, run the search.
      const searchParams = new URLSearchParams(window.location.search);
      if (searchParams.has('query')) {
        this.search(searchParams.get('query'));
      }
    } catch (e) {
      this.handleError(e);
    }
  },
  methods: {
    onSubmit() {
      if (this.query) {
        this.search(this.query);
      }
    },
    search(query) {
      this.query = query;
      this.submitted = true;

      // Run the search.
      this.results = window.idx.search(this.query);

      // Limit the results by relevancy score.
      this.results = this.results.filter((key) => key.score > this.relevancy_threshold);

      // Add page titles to the result set.
      Object.keys(this.results).forEach((key) => {
        const contentItem = this.contentMap.find(({ id }) => id === this.results[key].ref);
        this.results[key].title = contentItem.h1;
      });

      // Add the search term to the URL to allow linking to result pages.
      const url = new URL(window.location);
      url.searchParams.set('query', this.query);
      window.history.pushState(null, '', url.toString());
    },
    handleError() {
      this.error = true;
    },
  },
};
</script>

<template>
  <div class="lunr-search">
    <h1>Search</h1>
    <gl-search-box-by-click v-model="query" :value="query" @submit="onSubmit" />
    <div v-if="results.length" class="gl-font-sm gl-mb-6">{{ results.length }} results found</div>

    <ul v-if="results.length">
      <li v-for="result in results" :key="result.ref">
        <gl-link :href="`/${result.ref}`">{{ result.title }}</gl-link>
      </li>
    </ul>

    <p v-if="noResults" class="gl-py-5">No results found.</p>
    <p v-if="error" class="gl-py-5" data-testid="lunr-error">Error fetching search index.</p>
  </div>
</template>
