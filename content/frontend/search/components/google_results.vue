<script>
/* global GOOGLE_SEARCH_KEY */
import {
  GlSearchBoxByClick,
  GlLink,
  GlLoadingIcon,
  GlSafeHtmlDirective as SafeHtml,
  GlPagination,
} from '@gitlab/ui';
import isEqual from 'lodash.isequal';
import { getSearchQueryFromURL, updateURLParams } from '../search_helpers';
import { GPS_ENDPOINT, GPS_ID } from '../../services/google_search_api';
import SearchFilters from './search_filters.vue';

export default {
  components: {
    SearchFilters,
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
      activeFilters: [],
    };
  },
  computed: {
    resultSummary() {
      const { count, startIndex } = this.response.queries.request[0];
      const end = startIndex - 1 + count;
      return `Showing ${startIndex}-${end} of ${this.response.searchInformation.formattedTotalResults} results`;
    },
    noResults() {
      return this.query && !this.loading && !this.results.length && !this.error;
    },
    showPager() {
      return (
        this.submitted &&
        this.results.length &&
        this.response.searchInformation.totalResults > this.MAX_RESULTS_PER_PAGE &&
        !this.loading
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
      this.search(this.query, this.activeFilters);
    }
  },
  methods: {
    cleanTitle(title) {
      return title.replace(' | GitLab', '');
    },
    async fetchGoogleResults(filters) {
      let data = {};

      // Construct the query string for additional filters if needed.
      const filterQuery = filters.length
        ? `+more:pagemap:metatags-gitlab-docs-section:${filters.join(',')}`
        : '';

      try {
        const response = await fetch(
          GPS_ENDPOINT +
            new URLSearchParams({
              key: GOOGLE_SEARCH_KEY,
              cx: GPS_ID,
              q: `${this.query}${filterQuery}`.replaceAll(' ', '*'),
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
      this.loading = false;
      throw new Error(`Error code ${error.code}: ${error.message}`);
    },
    async search(query, filters) {
      this.results = [];
      if (!query) return;

      // If the query or filters changed, return to page 1 of results.
      if (query !== this.query || !isEqual(filters, this.activeFilters)) this.pageNumber = 1;

      this.query = query;
      this.activeFilters = filters;

      try {
        this.loading = true;
        this.response = await this.fetchGoogleResults(filters);
        this.results = this.response.items ? this.response.items : [];
      } catch (error) {
        this.handleError(error);
      } finally {
        this.loading = false;
        this.submitted = true;
        updateURLParams(this.query);

        // Add a relative link to each result object.
        this.results = this.results.map((obj) => ({
          ...obj,
          relativeLink: obj.link.replace('https://docs.gitlab.com/', '/'),
        }));
      }
    },
  },
};
</script>

<template>
  <div class="google-search gl-mb-9">
    <h1>Search</h1>
    <div class="gl-h-11 gl-mb-5">
      <gl-search-box-by-click
        v-model="query"
        :value="query"
        @submit="search(query, activeFilters)"
      />
      <div v-if="results.length" class="gl-font-sm gl-mb-5 gl-ml-1">
        {{ resultSummary }}
      </div>
    </div>

    <div class="results-container gl-lg-display-flex">
      <div v-if="submitted" class="results-sidebar gl-mb-5 lg-w-20p">
        <h2 class="gl-mt-0! gl-mb-5!">Filter results</h2>
        <search-filters @filteredSearch="(filters) => search(query, filters)" />
      </div>

      <div class="lg-w-70p">
        <gl-loading-icon v-if="loading" size="lg" class="gl-mt-5 gl-text-center" />

        <ul v-if="results.length" class="gl-list-style-none gl-pl-2" data-testid="search-results">
          <li v-for="result in results" :key="result.cacheId" class="gl-mb-5!">
            <gl-link
              :href="`${result.relativeLink}`"
              class="gl-font-lg gl-border-bottom-0! gl-hover-text-decoration-underline:hover gl-mb-2"
              >{{ cleanTitle(result.title) }}
            </gl-link>
            <p v-safe-html="result.htmlSnippet" class="result-snippet"></p>
          </li>
        </ul>

        <gl-pagination
          v-if="showPager"
          v-model="pageNumber"
          :per-page="MAX_RESULTS_PER_PAGE"
          :total-items="pagerMaxItems"
          class="gl-mt-9"
          @input="search(query, activeFilters)"
        />

        <p v-if="noResults" class="gl-py-5">
          No results found. Try adjusting your search terms, or searching the
          <gl-link class="gl-font-base" href="https://forum.gitlab.com/">community forum</gl-link>.
        </p>
        <p v-if="error" class="gl-py-5" data-testid="search-error">
          Error fetching results. Please try again later.
        </p>
      </div>
    </div>
  </div>
</template>

<style>
html {
  overflow-y: scroll;
}
.result-snippet {
  font-size: 0.875rem;
}
.results-sidebar h2 {
  font-size: 1.5rem;
}
</style>
