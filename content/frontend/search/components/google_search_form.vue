<script>
import {
  GlSearchBoxByType,
  GlLink,
  GlSafeHtmlDirective as SafeHtml,
  GlTooltipDirective as GlTooltip,
} from '@gitlab/ui';
import { debounce } from 'lodash';
import { directive as clickOutside } from 'v-click-outside';
import { fetchResults } from '../../services/google_search_api';
import SuggestedItems from './suggested_items.vue';

export default {
  components: {
    GlSearchBoxByType,
    GlLink,
    SuggestedItems,
  },
  directives: {
    clickOutside,
    SafeHtml,
    GlTooltip,
  },
  props: {
    borderless: {
      type: Boolean,
      required: true,
    },
    numResults: {
      type: Number,
      required: true,
    },
  },
  data() {
    return {
      activeLink: -1,
      historyItems: 0,
      isLoading: false,
      moreResultsPath: '',
      results: [],
      showTooltip: true,
      suggestion: '',
      searchQuery: '',
      showModal: false,
      showResultPanel: false,
      submitted: false,
      totalCount: 0,
    };
  },
  computed: {
    hasMoreResults() {
      return this.results.length >= this.numResults;
    },
    hasNoResults() {
      return !this.results.length && this.submitted && this.searchQuery;
    },
    showSuggested() {
      return !this.searchQuery;
    },
  },
  watch: {
    searchQuery() {
      this.results = [];
      this.showResultPanel = false;
      this.showTooltip = this.searchQuery.length === 0;
      this.submitted = false;
      this.moreResultsPath = `/search/?q=${encodeURI(this.searchQuery)}`;
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

      const query = this.suggestion ? this.suggestion : this.searchQuery;
      const response = await fetchResults(query, [], 1, this.numResults);
      this.isLoading = false;
      this.suggestion = '';

      this.totalCount =
        response.searchInformation && response.searchInformation.totalCount
          ? response.searchInformation.totalCount
          : 0;
      this.results = response.items ? response.items : [];

      // If there were no results, try the spelling suggestion if present.
      if (!this.results.length && response.spelling) {
        this.suggestion = response.spelling.correctedQuery;
        this.getResults();
      }

      this.submitted = true;
      this.showResultPanel = true;
    },
    showAllResults() {
      // Sends the user to the advanced search page if they hit Enter.
      if (this.searchQuery) {
        window.location.href = this.moreResultsPath;
      }
    },
    keyboardNav(e) {
      const isArrowUp = e.key === 'ArrowUp';
      const isArrowDown = e.key === 'ArrowDown';
      const searchBox = document.querySelector('input[type=search]');

      if (isArrowUp || isArrowDown) {
        const activeIndex = this.activeLink + (isArrowUp ? -1 : 1);

        // If we're at the top or bottom of the list, go back to the search box.
        const listLength = this.searchQuery ? this.results.length : this.historyItems - 1;
        if (activeIndex < 0 || activeIndex > listLength) {
          this.activeLink = -1;
          searchBox.focus();
          // Reset the value after focus so that the cursor is at the end of the text.
          searchBox.value = this.searchQuery;
          return;
        }
        // Otherwise, select the previous or next link.
        this.setActiveResult(document.querySelector(`[data-link-index="${activeIndex}"]`));
      }
    },
    setActiveResult(result) {
      result.focus();
      this.activeLink = Number(result.dataset.linkIndex);
    },
    deactivate() {
      this.showResultPanel = false;
      this.showModal = false;
      this.activeLink = -1;
      this.showTooltip = this.searchQuery.length === 0;
    },
  },
};
</script>

<template>
  <div>
    <div
      v-click-outside="() => deactivate()"
      class="gs-wrapper gl-m-auto gl-my-3 gl-md-mt-0 gl-md-mb-0"
      @keydown.arrow-down.prevent="keyboardNav"
      @keydown.arrow-up.prevent="keyboardNav"
      @keydown.escape="deactivate()"
      @keydown.tab="deactivate()"
    >
      <form class="gl-relative">
        <gl-search-box-by-type
          v-model="searchQuery"
          :is-loading="isLoading"
          :borderless="borderless"
          placeholder=""
          autocomplete="off"
          aria-label="Search"
          @focus="
            showResultPanel = true;
            showModal = true;
          "
          @keydown.enter.prevent="showAllResults()"
        />
        <kbd
          v-show="showTooltip && !isLoading"
          v-gl-tooltip.bottom.hover.html
          class="gl-absolute gl-z-index-1 gl-bg-gray-100 gl-text-gray-700"
          title="Use the shortcut keys<br><kbd>/</kbd> or <kbd>s</kbd> to start a search"
          >/</kbd
        >
      </form>

      <div
        v-if="showResultPanel"
        class="gs-results gl-absolute gl-z-index-200 gl-bg-white gl-px-4 gl-rounded gl-shadow"
      >
        <ul v-if="results.length" data-testid="search-results" class="gl-pl-0 gl-mb-0 gl-py-3">
          <li v-for="(result, index) in results" :key="result.cacheId" class="gl-list-style-none">
            <gl-link
              data-result-type="dropdown"
              :data-search-query="searchQuery"
              :href="result.relativeLink"
              :data-link-index="index"
              class="gl-text-gray-700 gl-py-3 gl-px-2 gl-display-block gl-text-left"
            >
              <span v-safe-html="result.formattedTitle" class="gl-display-block"></span>
              <span
                v-if="result.breadcrumbs"
                v-safe-html="result.breadcrumbs"
                class="gl-font-xs gl-display-block gl-text-gray-400"
              ></span>
            </gl-link>
          </li>
          <li v-if="hasMoreResults" class="gl-list-style-none gl-mb-1">
            <gl-link
              :data-link-index="results.length"
              data-testid="more-results"
              :href="moreResultsPath"
              class="gl-text-gray-700 gl-pt-3 gl-pb-3 gl-px-2 gl-display-block gl-text-left"
            >
              See all results
            </gl-link>
          </li>
        </ul>
        <p
          v-if="hasNoResults && !suggestion"
          data-testid="no-results"
          class="gl-text-left gl-pt-3 gl-my-2 gl-pb-2"
        >
          No results found.
        </p>
        <suggested-items
          v-if="showSuggested"
          @pageHistoryInit="(items) => (historyItems = items)"
        />
      </div>
    </div>
    <transition name="fade">
      <div v-if="showModal" class="gl-display-none gl-md-display-block modal-backdrop"></div>
    </transition>
  </div>
</template>
