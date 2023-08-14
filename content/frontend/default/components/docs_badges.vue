<script>
import { GlBadge, GlTooltipDirective, GlLink } from '@gitlab/ui';
import { badgeIndex } from '../../../_data/badges.yaml';

export default {
  components: {
    GlBadge,
    GlLink,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    badgesData: {
      type: Array,
      required: true,
    },
    isHeading: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      badges: [],
    };
  },
  created() {
    // Pull in more badge info from the badges.yaml file
    this.badgesData.forEach((badge) => {
      this.badges.push(badgeIndex.find((obj) => obj.id.includes(badge.text)));
    });
  },
  methods: {
    getBadgeVariant(type) {
      const variantMapping = {
        tier: 'tier',
        offering: 'info',
        status: 'neutral',
        content: 'warning',
      };
      return variantMapping[type] || '';
    },
    getBadgeSize(isHeading) {
      return isHeading ? 'md' : 'sm';
    },
  },
};
</script>

<template>
  <span :class="`docs-badges-wrapper badge-heading-${isHeading} gl-ml-2`">
    <gl-badge
      v-for="badge in badges"
      :key="badge"
      v-gl-tooltip.top
      :variant="getBadgeVariant(badge.type)"
      :title="badge.text"
      class="gl-mr-2"
      :size="getBadgeSize(isHeading)"
    >
      <component
        :is="badge.link ? 'GlLink' : 'span'"
        :href="badge.link"
        class="docs-badge gl-font-sm"
      >
        {{ badge.label }}
      </component>
    </gl-badge>
  </span>
</template>
