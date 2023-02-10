<script>
/* global GOOGLE_SEARCH_KEY */
import {
  GlSearchBoxByClick,
  GlLink,
  GlLoadingIcon,
  GlSafeHtmlDirective as SafeHtml,
  GlPagination,
} from '@gitlab/ui';
import { getSearchQueryFromURL, updateURLParams } from '../search_helpers';
import { GPS_ENDPOINT, GPS_ID } from '../../services/google_search_api';

export default {
  components: {
    GlSearchBoxByClick,
    GlLink,
    GlLoadingIcon,
    GlPagination,
  },
  directives: {
    SafeHtml,
  },
  data() {
    const queryParam = getSearchQueryFromURL();
    return {
      query: queryParam || '',
      submitted: false,
      loading: false,
      error: false,
      pageNumber: 1,
      response: {},
      results: [],
    };
  },
  computed: {
    resultSummary() {
      const { count, startIndex } = this.response.queries.request[0];
      const end = startIndex - 1 + count;
      return `Showing ${startIndex}-${end} of ${this.response.searchInformation.formattedTotalResults} results`;
    },
    noResults() {
      return this.submitted && !this.loading && !this.results.length && !this.error;
    },
    showPager() {
      return (
        this.submitted && this.response.searchInformation.totalResults > this.MAX_RESULTS_PER_PAGE
      );
    },
    pagerMaxItems() {
      return Math.min(this.response.searchInformation.totalResults, this.MAX_TOTAL_RESULTS);
    },
  },
  created() {
    // Limits from the Google API
    this.MAX_RESULTS_PER_PAGE = 10;
    this.MAX_TOTAL_RESULTS = 100;
  },
  mounted() {
    if (this.query) {
      this.search(this.query);
    }
  },
  methods: {
    cleanTitle(title) {
      return title.replace(' | GitLab', '');
    },
    async fetchGoogleResults() {
      let data = {};
      try {
        const response = await fetch(
          GPS_ENDPOINT +
            new URLSearchParams({
              key: GOOGLE_SEARCH_KEY,
              cx: GPS_ID,
              q: this.query,
              start: (this.pageNumber - 1) * this.MAX_RESULTS_PER_PAGE + 1,
            }),
        );
        data = await response.json();
        if (!response.ok) this.handleError(data.error);
      } catch (error) {
        this.handleError(error);
      }
      return data;
    },
    handleError(error) {
      this.error = true;
      throw new Error(`Error code ${error.code}: ${error.message}`);
    },
    onSubmit() {
      if (this.query) {
        this.search(this.query);
      }
    },
    async search(query) {
      this.query = query;
      this.results = [];

      this.loading = true;
      this.response = await this.fetchGoogleResults();
      this.results = this.response.items ? this.response.items : [];
      this.loading = false;

      this.submitted = true;
      updateURLParams(this.query);
    },
  },
};
</script>

<template>
  <div class="google-search gl-mb-9">
    <h1>Search</h1>
    <gl-search-box-by-click v-model="query" :value="query" @submit="onSubmit" />
    <div v-if="results.length" class="gl-font-sm gl-mb-5">
      {{ resultSummary }}
    </div>

    <gl-loading-icon v-if="loading" size="lg" class="gl-mt-5" />

    <ul
      v-if="results.length"
      class="gl-list-style-none gl-pl-2 gl-max-w-80"
      data-testid="search-results"
    >
      <li v-for="result in results" :key="result.cacheId" class="gl-mb-5!">
        <gl-link
          :href="`${result.link}`"
          class="gl-font-lg gl-border-bottom-0! gl-hover-text-decoration-underline:hover gl-mb-2"
          >{{ cleanTitle(result.title) }}</gl-link
        >
        <p v-safe-html="result.htmlSnippet" class="result-snippet"></p>
      </li>
    </ul>

    <gl-pagination
      v-if="showPager"
      v-model="pageNumber"
      :per-page="MAX_RESULTS_PER_PAGE"
      :total-items="pagerMaxItems"
      class="gl-mt-9"
      @input="search(query)"
    />

    <p v-if="noResults" class="gl-py-5">No results found.</p>
    <p v-if="error" class="gl-py-5" data-testid="search-error">
      Error fetching results. Please try again later.
    </p>
  </div>
</template>

<style scoped>
.result-snippet {
  font-size: 0.875rem;
}
</style>
