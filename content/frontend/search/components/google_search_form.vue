<script>
import { GlSearchBoxByType, GlLink, GlSafeHtmlDirective as SafeHtml } from '@gitlab/ui';
import { debounce } from 'lodash';
import { directive as clickOutside } from 'v-click-outside';
import { fetchResults, MAX_RESULTS_PER_PAGE } from '../../services/google_search_api';

export default {
  components: {
    GlSearchBoxByType,
    GlLink,
  },
  directives: {
    clickOutside,
    SafeHtml,
  },
  props: {
    borderless: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      isLoading: false,
      moreResultsPath: '',
      results: [],
      searchQuery: '',
      showResultPanel: false,
      submitted: false,
      totalCount: 0,
    };
  },
  computed: {
    hasMoreResults() {
      return this.results.length >= MAX_RESULTS_PER_PAGE;
    },
    hasNoResults() {
      return !this.results.length && this.submitted && this.searchQuery;
    },
  },
  watch: {
    searchQuery() {
      this.debouncedGetResults();
    },
  },
  created() {
    this.debouncedGetResults = debounce(this.getResults, 500);
  },
  methods: {
    async getResults() {
      this.showResultPanel = false;

      this.isLoading = true;
      const response = await fetchResults(this.searchQuery, [], 1, 10);
      this.isLoading = false;

      this.totalCount =
        response.searchInformation && response.searchInformation.totalCount
          ? response.searchInformation.totalCount
          : 0;
      this.results = response.items ? response.items : [];
      this.moreResultsPath = `/search/?q=${encodeURI(this.searchQuery)}`;
      this.submitted = true;
      this.showResultPanel = true;
    },
    showAllResults() {
      // Sends the user to the advanced search page if they hit Enter.
      window.location.href = this.moreResultsPath;
    },
  },
};
</script>

<template>
  <div
    v-click-outside="() => (showResultPanel = false)"
    class="gs-wrapper gl-m-auto gl-my-3 gl-md-mt-0 gl-md-mb-0"
  >
    <gl-search-box-by-type
      v-model="searchQuery"
      :is-loading="isLoading"
      :borderless="borderless"
      placeholder=""
      @focus="showResultPanel = true"
      @keyup.enter="showAllResults()"
    />
    <div
      v-if="showResultPanel && submitted"
      class="gs-results gl-absolute gl-z-index-200 gl-bg-white gl-rounded gl-px-3 gl-shadow"
    >
      <ul v-if="results.length" data-testid="search-results" class="gl-pl-0 gl-mb-0">
        <li v-for="result in results" :key="result.cacheId" class="gl-list-style-none">
          <gl-link
            v-safe-html="result.formattedTitle"
            :href="result.relativeLink"
            class="gl-text-gray-700 gl-py-3 gl-px-2 gl-display-block gl-text-left"
          />
        </li>
        <li v-if="hasMoreResults" class="gl-list-style-none gl-border-t gl-my-2 gl-py-2">
          <gl-link
            data-testid="more-results"
            :href="moreResultsPath"
            class="gl-text-gray-700 gl-py-3 gl-pb-2 gl-px-2 gl-display-block gl-text-left"
          >
            See all results
          </gl-link>
        </li>
      </ul>
      <p v-if="hasNoResults" data-testid="no-results" class="gl-text-left gl-pt-3 gl-my-2 gl-pb-2">
        No results found.
      </p>
    </div>
  </div>
</template>
