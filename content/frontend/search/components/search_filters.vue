<script>
import { GlFormCheckboxGroup, GlFormCheckbox } from '@gitlab/ui';

export default {
  name: 'SearchFilters',
  components: {
    GlFormCheckboxGroup,
    GlFormCheckbox,
  },
  data() {
    return {
      selected: [],
    };
  },
  created() {
    this.filters = [
      {
        title: 'Filter by',
        options: [
          {
            text: 'Installation docs',
            value: 'Install,Subscribe',
          },
          {
            text: 'Administration docs',
            value: 'Administer,Subscribe',
          },
          {
            text: 'User docs',
            value: 'Use GitLab,Tutorials,Subscribe',
          },
          {
            text: 'Developer (API) docs',
            value: 'Develop',
          },
          {
            text: 'Contributor docs',
            value: 'Contribute',
          },
        ],
      },
    ];
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
          docs_search_filter_type: option.text.split(' ')[0].toLowerCase(),
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
      <gl-form-checkbox-group v-model="selected" :label="filter.title">
        <gl-form-checkbox
          v-for="option in filter.options"
          :key="option.value"
          :value="option.value"
          @input="$emit('filteredSearch', selected)"
          @change="trackFilterChange(option)"
        >
          {{ option.text }}
        </gl-form-checkbox>
      </gl-form-checkbox-group>
    </div>
  </div>
</template>
