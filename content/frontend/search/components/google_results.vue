<script>
import {
  GlSearchBoxByClick,
  GlLink,
  GlLoadingIcon,
  GlSafeHtmlDirective as SafeHtml,
  GlPagination,
} from '@gitlab/ui';
import isEqual from 'lodash.isequal';
import { getSearchParamsFromURL, updateURLParams, convertFilterValues } from '../search_helpers';
import {
  fetchResults,
  MAX_RESULTS_PER_PAGE,
  MAX_TOTAL_RESULTS,
} from '../../services/google_search_api';
import SearchFilters from './search_filters.vue';
import VersionSearch from './version_search.vue';

export default {
  components: {
    SearchFilters,
    VersionSearch,
    GlSearchBoxByClick,
    GlLink,
    GlLoadingIcon,
    GlPagination,
  },
  directives: {
    SafeHtml,
  },
  data() {
    const { qParam, pageParam, filterParam } = getSearchParamsFromURL();
    return {
      query: qParam || '',
      submitted: false,
      loading: false,
      error: false,
      pageNumber: Number(pageParam) || 1,
      response: {},
      results: [],
      activeFilters: convertFilterValues(filterParam.split(','), false) || [],
      suggestion: '',
      correctedTerm: '',
    };
  },
  computed: {
    resultSummary() {
      const { count, startIndex } = this.response.queries.request[0];
      const end = startIndex - 1 + count;
      return `Showing ${startIndex}-${end} of ${this.pagerMaxItems()} results`;
    },
    noResults() {
      return (
        this.query &&
        this.submitted &&
        !this.results.length &&
        !this.loading &&
        !this.error &&
        !this.suggestion
      );
    },
    showPager() {
      return (
        this.submitted &&
        this.results.length &&
        this.response.searchInformation.totalResults > MAX_RESULTS_PER_PAGE &&
        !this.loading
      );
    },
  },
  created() {
    // Provides this constant for the template.
    this.MAX_RESULTS_PER_PAGE = MAX_RESULTS_PER_PAGE;
  },
  mounted() {
    if (this.query) {
      this.search(this.query, this.activeFilters);
    }
  },
  methods: {
    pagerMaxItems() {
      return Math.min(this.response.searchInformation.totalResults, MAX_TOTAL_RESULTS);
    },
    handleError(error) {
      this.error = true;
      this.loading = false;
      throw new Error(`Error code ${error.code}: ${error.message}`);
    },
    formatSuggestion(suggestion) {
      // Drop the "+more" and any subsequent text from the correction.
      // These are filter values, which we include elsewhere.
      return suggestion.split('+more').shift().trim().replaceAll('+', ' ');
    },
    async search(query, filters, corrected = false) {
      this.results = [];
      if (!query) return;

      // If the query or filters changed, return to page 1 of results.
      if (query !== this.query || !isEqual(filters, this.activeFilters)) this.pageNumber = 1;

      // Drop any previously-set spelling suggestions if this search was not rewritten.
      if (!corrected) {
        this.suggestion = '';
        this.correctedTerm = '';
      }

      this.query = query;
      this.activeFilters = filters;

      try {
        this.loading = true;
        this.response = await fetchResults(query, filters, this.pageNumber, MAX_RESULTS_PER_PAGE);
        this.results = this.response.items ? this.response.items : [];

        // If there were no results, use the spelling suggestion if present.
        if (!this.results.length && this.response.spelling) {
          this.suggestion = this.formatSuggestion(this.response.spelling.correctedQuery);
          this.correctedTerm = query;
          // Run a new search with the spelling suggestion.
          this.search(this.suggestion, filters, true);
        }
      } catch (error) {
        this.handleError(error);
      } finally {
        this.loading = false;
        this.submitted = true;
        updateURLParams({
          q: this.query,
          page: this.pageNumber,
          filters: convertFilterValues(this.activeFilters, true),
        });
      }
    },
  },
};
</script>

<template>
  <div class="google-search gl-mb-9">
    <h1 class="gl-pt-0! gl-mt-7!">Search the latest docs</h1>
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
        <search-filters
          :initial-selected="activeFilters"
          @filteredSearch="(filters) => search(query, filters)"
        />

        <version-search :query="query" />
      </div>

      <div class="lg-w-70p">
        <gl-loading-icon v-if="loading" size="lg" class="gl-mt-5 gl-text-center" />

        <p v-if="correctedTerm && !loading" class="gl-py-4">
          No results found for
          <span class="gl-font-weight-bold gl-font-style-italic">{{ correctedTerm }}</span
          >. Showing results for
          <span class="gl-font-weight-bold gl-font-style-italic">{{ suggestion }}</span> instead.
        </p>

        <ul v-if="results.length" class="gl-list-style-none gl-pl-2" data-testid="search-results">
          <li v-for="result in results" :key="result.cacheId" class="gl-mb-5!">
            <gl-link
              v-safe-html="result.formattedTitle"
              data-result-type="page"
              :href="`${result.relativeLink}`"
              class="gl-font-lg gl-border-bottom-0! gl-hover-text-decoration-underline:hover gl-mb-2"
            />
            <p
              v-if="result.breadcrumbs"
              v-safe-html="result.breadcrumbs"
              class="gl-font-sm gl-text-gray-400"
            ></p>
            <p v-safe-html="result.htmlSnippet" class="result-snippet gl-mt-0!"></p>
          </li>
        </ul>

        <gl-pagination
          v-if="showPager"
          v-model="pageNumber"
          :per-page="MAX_RESULTS_PER_PAGE"
          :total-items="pagerMaxItems()"
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
