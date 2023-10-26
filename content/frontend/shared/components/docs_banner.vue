<script>
import { GlAlert, GlIcon, GlSafeHtmlDirective as SafeHtml } from '@gitlab/ui';
import { getCookie, setCookie } from '../cookies';

export default {
  directives: {
    SafeHtml,
  },
  components: {
    GlAlert,
    GlIcon,
  },
  props: {
    text: {
      type: String,
      required: true,
    },
    variant: {
      type: String,
      required: true,
    },
    icon: {
      type: String,
      required: false,
      default: '',
    },
    isSticky: {
      type: Boolean,
      required: false,
      default: false,
    },
    dismissible: {
      type: Boolean,
      required: false,
      default: true,
    },
  },
  data() {
    return {
      showBanner: true,
    };
  },
  computed: {
    renderBanner() {
      return (this.showBanner || !this.dismissible) === true;
    },
  },
  created() {
    this.showBanner = getCookie('HideDocsBanner') !== '1';
  },
  methods: {
    dismissAlert() {
      this.showBanner = false;
      setCookie('HideDocsBanner', 1, 30);
    },
  },
};
</script>

<template>
  <gl-alert
    v-if="renderBanner"
    :sticky="isSticky"
    :variant="variant"
    :dismissible="dismissible"
    :show-icon="false"
    class="gl-font-base gl-docs gl-mt-6 gl-z-index-3"
    @dismiss="dismissAlert()"
  >
    <gl-icon v-if="icon" :name="icon" size="14" class="gl-mr-3 gl-vertical-align-middle!" />
    <div v-safe-html="text" class="gl-display-inline-block"></div>
  </gl-alert>
</template>
