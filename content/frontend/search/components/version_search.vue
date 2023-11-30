<script>
import { GlFormSelect, GlTooltipDirective as GlTooltip, GlIcon } from '@gitlab/ui';
import { getArchivesVersions } from '../../services/fetch_versions';

const SELECT_DEFAULT_TEXT = 'Select a version';

export default {
  components: {
    GlFormSelect,
    GlIcon,
  },
  directives: {
    GlTooltip,
  },
  props: {
    query: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      selectedVersion: SELECT_DEFAULT_TEXT,
      archiveOptions: [],
    };
  },
  async created() {
    try {
      const archiveVersions = await getArchivesVersions();
      archiveVersions.push(SELECT_DEFAULT_TEXT);

      /**
       * Omit versions with non-functional versioned search.
       * We can remove this list and the filter method below after
       * 15.5 and lower are retired (18.0 release/May 2025).
       */
      const unsupported = [
        '14.0',
        '14.1',
        '14.2',
        '14.3',
        '14.4',
        '14.5',
        '14.6',
        '14.7',
        '14.8',
        '14.9',
        '15.0',
        '15.1',
        '15.2',
        '15.3',
        '15.4',
        '15.5',
      ];
      // Build the option list.
      this.archiveOptions = archiveVersions
        .filter((v) => !unsupported.includes(v))
        .map((text) => ({ text, value: text }))
        .reverse();
    } catch (err) {
      throw new Error(`Error fetching archives list: ${err}`);
    }
  },
  methods: {
    searchArchivedVersion() {
      if (this.selectedVersion !== SELECT_DEFAULT_TEXT) {
        // In 15.11, the search query string changed from "query" to "q".
        // This logic can be removed when 15.x sites are retired (18.0 release).
        const versionNumber = Number(this.selectedVersion);
        const queryParam = versionNumber < 16.0 && versionNumber !== 15.11 ? 'query' : 'q';

        window.location.href = `https://archives.docs.gitlab.com/${
          this.selectedVersion
        }/search/?${queryParam}=${encodeURI(this.query)}`;

        this.selectedVersion = SELECT_DEFAULT_TEXT;
      }
    },
  },
};
</script>

<template>
  <div>
    <h2 class="gl-font-lg! gl-mb-3! gl-mt-6!">
      Search the archives
      <gl-icon
        v-gl-tooltip.right.hover.html
        name="information"
        size="12"
        class="gl-vertical-align-middle!"
        title="Docs archives use a simplified search engine. You may find fewer results when searching past versions."
      />
    </h2>
    <gl-form-select
      v-model="selectedVersion"
      :options="archiveOptions"
      class="gl-max-w-20"
      @change="searchArchivedVersion()"
    />
  </div>
</template>
