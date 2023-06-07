<script>
import { GlFormCheckboxGroup, GlFormCheckbox } from '@gitlab/ui';
import { SEARCH_FILTERS } from '../search_helpers';

export default {
  name: 'SearchFilters',
  components: {
    GlFormCheckboxGroup,
    GlFormCheckbox,
  },
  props: {
    initialSelected: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      selected: [],
    };
  },
  watch: {
    initialSelected: {
      immediate: true,
      handler(newValues) {
        this.selected = newValues;
      },
    },
  },
  created() {
    this.filters = SEARCH_FILTERS;
  },
  methods: {
    /**
     * Send click events to Google Analytics.
     */
    trackFilterChange(option) {
      window.dataLayer = window.dataLayer || [];
      if (this.selected.includes(option.value)) {
        window.dataLayer.push({
          event: 'docs_search_filter',
          docs_search_filter_type: option.id,
        });
      }
    },
  },
};
</script>

<template>
  <div>
    <div v-for="filter in filters" :key="filter.title">
      <h2 class="gl-font-lg! gl-mt-0! gl-mb-3!">{{ filter.title }}</h2>
      <gl-form-checkbox-group
        v-model="selected"
        :label="filter.title"
        @input="$emit('filteredSearch', selected)"
      >
        <gl-form-checkbox
          v-for="option in filter.options"
          :key="option.id"
          :value="option.value"
          @change="trackFilterChange(option)"
        >
          {{ option.text }}
        </gl-form-checkbox>
      </gl-form-checkbox-group>
    </div>
  </div>
</template>
