<script>
import { GlFormCheckboxGroup } from '@gitlab/ui';

export default {
  name: 'SearchFilters',
  components: {
    GlFormCheckboxGroup,
  },
  data() {
    return {
      selected: [],
    };
  },
  created() {
    this.filters = [
      {
        title: 'Sections',
        options: ['Tutorials', 'Install', 'Administer', 'Use GitLab', 'Develop', 'Contribute'],
      },
    ];
  },
};
</script>

<template>
  <div>
    <div v-for="filter in filters" :key="filter.title">
      <h3 class="gl-font-lg! gl-mt-5! gl-mb-3!">{{ filter.title }}</h3>
      <gl-form-checkbox-group
        v-model="selected"
        :label="filter.title"
        :options="filter.options"
        @input="$emit('filteredSearch', selected)"
      />
    </div>
  </div>
</template>
