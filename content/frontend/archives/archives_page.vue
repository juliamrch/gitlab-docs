<script>
import { getVersions, getArchiveImages } from '../services/fetch_versions';
import HeaderPermalink from '../shared/components/header_permalink.vue';

export default {
  components: {
    HeaderPermalink,
  },
  data() {
    return {
      versions: {},
      archiveImages: [],
    };
  },
  async created() {
    this.versions = await getVersions();
    this.archiveImages = await getArchiveImages();
  },
};
</script>

<template>
  <div>
    <header-permalink text="Latest released version" />
    <p>
      The latest released stable version is
      <a
        :data-testid="`current-stable-${versions.current}`"
        :href="`https://docs.gitlab.com/${versions.current}`"
        >{{ versions.current }}</a
      >.
    </p>

    <header-permalink text="Previously released versions" />
    <p>
      <a href="https://about.gitlab.com/support/statement-of-support/#version-support"
        >Supported versions</a
      >
      of GitLab Docs are available online on the
      <a href="https://archives.docs.gitlab.com">GitLab Docs Archives website</a>.
    </p>

    <div v-if="archiveImages.length">
      <header-permalink text="Offline archives" />
      <p>
        The following archives are available and can be browsed offline. You'll need to have
        <a href="https://docs.docker.com/get-docker/">Docker</a>
        installed to access them.
      </p>

      <div v-for="o in archiveImages" :key="o.name" :data-testid="`offline-version-${o.name}`">
        <h3>{{ o.name }}</h3>
        <div class="highlight">
          <pre class="highlight shell">
            <code>docker run <span class="nt">-it</span> <span class="nt">--rm</span> <span class="nt">-p</span> 4000:4000 {{ o.location }}</code>
          </pre>
        </div>
      </div>
    </div>
  </div>
</template>
