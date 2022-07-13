<script>
import { GlFormSelect } from '@gitlab/ui';

export default {
  components: {
    GlFormSelect,
  },
  props: {
    milestonesList: {
      type: Array,
      required: true,
    },
    showAllText: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      selected: this.showAllText,
    };
  },
  created() {
    // Pre-filter the page if the URL includes a valid version parameter.
    const searchParams = new URLSearchParams(window.location.search);
    if (!searchParams.has('removal_milestone')) {
      return;
    }
    const version = searchParams.get('removal_milestone').replace(/\./g, '');
    if (this.isValidVersion(version)) {
      this.filterDeprecationList(version);
      this.selected = version;
    }
  },
  methods: {
    isValidVersion(version) {
      return this.milestonesList.some((e) => e.value === version);
    },
    updateURLParams(option) {
      const item = this.milestonesList.find((x) => x.value === option);
      const url = new URL(window.location);

      if (item.text.length > 0 && item.text !== this.showAllText) {
        url.searchParams.set('removal_milestone', item.text);
      } else {
        url.searchParams.delete('removal_milestone');
      }
      window.history.pushState(null, '', url.toString());
    },
    /**
     * Filters the page down to a specified removal version.
     *
     * This method hides all deprecations that do not have the selected version
     * in their wrapper div's class lists.
     *
     * @param {String} option
     */
    filterDeprecationList(option) {
      const hiddenClass = 'd-none';

      // Reset the list and show all deprecations and headers.
      document.querySelectorAll('.deprecation, h2').forEach(function showAllSections(el) {
        el.classList.remove(hiddenClass);
      });

      if (option !== this.showAllText) {
        // Hide deprecations with non-selected versions.
        document
          .querySelectorAll(`.deprecation:not(.removal-${option})`)
          .forEach(function hideDeprecationsAndHeader(el) {
            el.classList.add(hiddenClass);
            // Hide the "announcement version" section header.
            el.parentElement.children[0].classList.add(hiddenClass);
          });

        // Show the "announcement version" header if we have deprecations in this section.
        document
          .querySelectorAll(`.deprecation.removal-${option}`)
          .forEach(function showHeader(el) {
            el.parentElement.children[0].classList.remove(hiddenClass);
          });
      }

      // Update the removal_milestone parameter in the URL.
      this.updateURLParams(option);
    },
  },
};
</script>

<template>
  <div class="mt-3 row">
    <div class="col-4">
      <label for="milestone" class="d-block col-form-label">Filter by removal version:</label>
      <gl-form-select
        v-model="selected"
        name="milestone"
        :options="milestonesList"
        data-testid="removal-milestone-filter"
        @change="filterDeprecationList(selected)"
      />
    </div>
  </div>
</template>
