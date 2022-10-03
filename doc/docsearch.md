# Search

GitLab Docs uses either Algolia DocSearch or Lunr.js as a search backend, depending on where the instance is hosted. The primary production site, docs.gitlab.com, runs Algolia.

## Algolia DocSearch

GitLab is a member of the [Algolia's DocSearch program](https://docsearch.algolia.com/),
which is a free tier of [Algolia](https://www.algolia.com/). We use
[DocSearch](https://github.com/algolia/docsearch) for the docs site's search function.

Algolia [crawls](#configure-the-algolia-crawler) our documentation, pushes the content to an
[index](https://www.algolia.com/doc/guides/sending-and-managing-data/manage-your-indices/),
and DocSearch provides a dropdown search experience on our website.

### DocSearch implementation details

DocSearch layouts are defined in various places:

- Home page: [`content/index.erb`](../content/index.erb)
- Dedicated search page under `/search`: [`layouts/instantsearch.html`](../layouts/instantsearch.html)
- Every other page: [`layouts/header.html`](../layouts/header.html)

A Javascript snippet initiates docsearch by using an API key, app ID,
and an index name that are needed for Algolia to show the results:

- Dedicated search page under `/search`: [`content/frontend/search/index.js`](../content/frontend/search/index.js)
- Every other page: [`content/frontend/search/docsearch.js`](../content/frontend/search/docsearch.js)

### Override DocSearch CSS

DocSearch defines its various classes starting with `DocSearch-`. To override those,
there's one file to edit:

- [`content/assets/stylesheets/_docsearch.scss`](../content/assets/stylesheets/_docsearch.scss)

### Navigate Algolia as a GitLab member

GitLab members can access Algolia's dashboard with the credentials that are
stored in 1Password (search for Algolia). After you log in, you can visit:

- The index dashboard
- The Algolia crawler

#### Browse the index dashboard

The [index dashboard](https://www.algolia.com/apps/3PNCFOU757/analytics/overview/gitlab)
provides information about the data that Algolia has extracted from the docs site.

Useful information:

- [Sorting](https://www.algolia.com/doc/guides/managing-results/refine-results/sorting/)
- [Custom ranking](https://www.algolia.com/doc/guides/managing-results/must-do/custom-ranking/)

#### Configure the Algolia crawler

An Algolia crawler does three things:

- Browses your website
- Extracts key information
- Sends the data to Algolia

You can change the way Algolia crawls our website to extract the search results:

1. Visit the
   [crawler editor](https://crawler.algolia.com/admin/crawlers/d46abdc0-bb41-4d50-95b7-a3e1fe6469a4/configuration/edit).
1. Make your changes.
   Algolia keeps a record of the previous edits in the **Configuration History** tab,
   so you can easily roll back in case something doesn't work as expected.
1. Select **Save**.
1. Go to the [overview page](https://crawler.algolia.com/admin/crawlers/d46abdc0-bb41-4d50-95b7-a3e1fe6469a4/overview)
   and select **Restart crawling**. Crawling takes about 50 minutes, our index
   data is about 2GB.

Read more about the crawler:

- [DocSearch crawler documentation](https://docsearch.algolia.com/docs/record-extractor)
- [Algolia crawler documentation](https://www.algolia.com/doc/tools/crawler/getting-started/overview/)
  - Watch this [short video](https://www.youtube.com/watch?v=w84K1cbUbmY) that
    explains what a crawler is and how it works.

#### Crawler and index settings configuration

The current crawler configuration can be found at the
[Algolia crawler dashboard](https://crawler.algolia.com/admin/crawlers/d46abdc0-bb41-4d50-95b7-a3e1fe6469a4/configuration/edit).

Make sure to keep the following snippet updated with that we use in production:

```js
new Crawler({
  appId: "3PNCFOU757",
  apiKey: "<do-not-expose-this-here>",
  rateLimit: 8,
  startUrls: ["https://docs.gitlab.com/"],
  renderJavaScript: true,
  sitemaps: ["https://docs.gitlab.com/sitemap.xml"],
  exclusionPatterns: ["**/index.html", "**/**README.html"],
  ignoreCanonicalTo: true,
  ignoreNoIndex: true,
  discoveryPatterns: ["https://docs.gitlab.com/**"],
  schedule: "every 1 day at 3:00 pm",
  actions: [
    {
      indexName: "gitlab",
      pathsToMatch: ["https://docs.gitlab.com/**"],
      recordExtractor: ({ $, helpers }) => {
        // Stop if one of those text is found in the DOM.
        const body = $.text();
        const toCheck = ["This document was moved to"];
        const shouldStop = toCheck.some((text) => body.includes(text));
        if (shouldStop) {
          return [];
        } // Removing DOM elements we don't want to crawl
        const toRemove = "#markdown-toc, .badge-trigger";
        $(toRemove).remove();

        return helpers.docsearch({
          recordProps: {
            lvl1: ".article-content h1",
            content:
              ".article-content p, .article-content li, .article-content td:last-child, .article-content pre.highlight code",
            lvl0: {
              selectors: ".article-content h1",
              defaultValue: "Documentation",
            },
            lvl2: ".article-content h2",
            lvl3: ".article-content h3",
            lvl4: ".article-content h4",
            lvl5: ".article-content h5, .article-content td:first-child",
          },
          indexHeadings: true,
          aggregateContent: true,
        });
      },
    },
  ],
  initialIndexSettings: {
    gitlab: {
      attributesForFaceting: ["type", "lang", "tags", "version", "language"],
      attributesToRetrieve: ["hierarchy", "content", "anchor", "url", "tags"],
      attributesToHighlight: ["hierarchy", "hierarchy_camel", "content"],
      attributesToSnippet: ["content:10"],
      camelCaseAttributes: ["hierarchy", "hierarchy_radio", "content"],
      searchableAttributes: [
        "unordered(hierarchy_radio_camel.lvl0)",
        "unordered(hierarchy_radio.lvl0)",
        "unordered(hierarchy_radio_camel.lvl1)",
        "unordered(hierarchy_radio.lvl1)",
        "unordered(hierarchy_radio_camel.lvl2)",
        "unordered(hierarchy_radio.lvl2)",
        "unordered(hierarchy_radio_camel.lvl3)",
        "unordered(hierarchy_radio.lvl3)",
        "unordered(hierarchy_radio_camel.lvl4)",
        "unordered(hierarchy_radio.lvl4)",
        "unordered(hierarchy_radio_camel.lvl5)",
        "unordered(hierarchy_radio.lvl5)",
        "unordered(hierarchy_radio_camel.lvl6)",
        "unordered(hierarchy_radio.lvl6)",
        "unordered(hierarchy_camel.lvl0)",
        "unordered(hierarchy.lvl0)",
        "unordered(hierarchy_camel.lvl1)",
        "unordered(hierarchy.lvl1)",
        "unordered(hierarchy_camel.lvl2)",
        "unordered(hierarchy.lvl2)",
        "unordered(hierarchy_camel.lvl3)",
        "unordered(hierarchy.lvl3)",
        "unordered(hierarchy_camel.lvl4)",
        "unordered(hierarchy.lvl4)",
        "unordered(hierarchy_camel.lvl5)",
        "unordered(hierarchy.lvl5)",
        "unordered(hierarchy_camel.lvl6)",
        "unordered(hierarchy.lvl6)",
        "content",
      ],
      distinct: true,
      attributeForDistinct: "url",
      customRanking: [
        "desc(pageRank)",
        "asc(level)",
        "desc(weight.level)",
        "asc(weight.position)",
      ],
      ranking: [
        "words",
        "filters",
        "typo",
        "attribute",
        "proximity",
        "exact",
        "custom",
      ],
      highlightPreTag: '<span class="algolia-docsearch-suggestion--highlight">',
      highlightPostTag: "</span>",
      minWordSizefor1Typo: 3,
      minWordSizefor2Typos: 7,
      allowTyposOnNumericTokens: false,
      minProximity: 1,
      ignorePlurals: true,
      advancedSyntax: true,
      attributeCriteriaComputedByMinProximity: true,
      removeWordsIfNoResults: "allOptional",
      separatorsToIndex: "_",
    },
  },
  indexPrefix: "",
});
```

The index settings configuration can be found under the
[`gitlab` index dashboard](https://www.algolia.com/apps/3PNCFOU757/explorer/browse/gitlab).

Make sure to keep the following snippet updated with that we use in production:

```json
{
  "settings": {
    "minWordSizefor1Typo": 3,
    "minWordSizefor2Typos": 7,
    "hitsPerPage": 20,
    "maxValuesPerFacet": 100,
    "minProximity": 1,
    "searchableAttributes": [
      "unordered(hierarchy_radio_camel.lvl0)",
      "unordered(hierarchy_radio.lvl0)",
      "unordered(hierarchy_radio_camel.lvl1)",
      "unordered(hierarchy_radio.lvl1)",
      "unordered(hierarchy_radio_camel.lvl2)",
      "unordered(hierarchy_radio.lvl2)",
      "unordered(hierarchy_radio_camel.lvl3)",
      "unordered(hierarchy_radio.lvl3)",
      "unordered(hierarchy_radio_camel.lvl4)",
      "unordered(hierarchy_radio.lvl4)",
      "unordered(hierarchy_radio_camel.lvl5)",
      "unordered(hierarchy_radio.lvl5)",
      "unordered(hierarchy_radio_camel.lvl6)",
      "unordered(hierarchy_radio.lvl6)",
      "unordered(hierarchy_camel.lvl0)",
      "unordered(hierarchy.lvl0)",
      "unordered(hierarchy_camel.lvl1)",
      "unordered(hierarchy.lvl1)",
      "unordered(hierarchy_camel.lvl2)",
      "unordered(hierarchy.lvl2)",
      "unordered(hierarchy_camel.lvl3)",
      "unordered(hierarchy.lvl3)",
      "unordered(hierarchy_camel.lvl4)",
      "unordered(hierarchy.lvl4)",
      "unordered(hierarchy_camel.lvl5)",
      "unordered(hierarchy.lvl5)",
      "unordered(hierarchy_camel.lvl6)",
      "unordered(hierarchy.lvl6)",
      "content"
    ],
    "numericAttributesToIndex": null,
    "attributesToRetrieve": [
      "hierarchy",
      "content",
      "anchor",
      "url",
      "tags"
    ],
    "allowTyposOnNumericTokens": false,
    "ignorePlurals": true,
    "camelCaseAttributes": [
      "hierarchy",
      "hierarchy_radio",
      "content"
    ],
    "advancedSyntax": true,
    "attributeCriteriaComputedByMinProximity": true,
    "distinct": true,
    "unretrievableAttributes": null,
    "optionalWords": null,
    "attributesForFaceting": [
      "lang",
      "language",
      "tags",
      "type",
      "filterOnly(version)"
    ],
    "attributesToSnippet": [
      "content:10"
    ],
    "attributesToHighlight": [
      "hierarchy",
      "hierarchy_camel",
      "content"
    ],
    "paginationLimitedTo": 1000,
    "attributeForDistinct": "url",
    "exactOnSingleWordQuery": "attribute",
    "ranking": [
      "typo",
      "words",
      "filters",
      "proximity",
      "attribute",
      "exact",
      "custom"
    ],
    "customRanking": [
      "asc(pageRank)",
      "asc(level)"
    ],
    "separatorsToIndex": "_",
    "removeWordsIfNoResults": "allOptional",
    "queryType": "prefixLast",
    "highlightPreTag": "<span class=\"algolia-docsearch-suggestion--highlight\">",
    "highlightPostTag": "</span>",
    "snippetEllipsisText": "",
    "alternativesAsExact": [
      "ignorePlurals",
      "singleWordSynonym"
    ]
  },
  "rules": [],
  "synonyms": []
}
```

#### Analytics and weekly reports of the search usage

You can view the search usage in the
[analytics dashboard](https://www.algolia.com/apps/3PNCFOU757/analytics/overview/gitlab).

If you want to receive weekly reports of the search usage, open a new
[access request](https://about.gitlab.com/handbook/engineering/#access-requests)
issue and ask that your email is added to the DocSearch alias (the same email as found in 1Password).

### Testing Algolia configuration changes

In order to test configuration changes without impacting docs.gitlab.com, you can create an additional
crawler via the [Algolia dashboard](https://crawler.algolia.com/admin/crawlers?sort=status&order=ASC&limit=20).
You can copy the config from the crawler that we use in production and make any changes you want. Make sure that
you change `indexName` to something that starts with `gitlab`, for example `gitlab_mytest`
(this is an Algolia [limitation](https://github.com/algolia/docsearch/issues/1392#issuecomment-1139907134)).

The new crawler will generate its own [index](https://www.algolia.com/apps/3PNCFOU757/indices), which can also be configured without impacting the production instance.

To use a test index from a review app or locally, update the `apiKey` and `indexName` fields in either:

- [DocSearch config](../content/assets/javascripts/docsearch.js) (homepage and navbar search).
- [InstantSearch config](../content/frontend/search/index.js) (dedicated search page).

You can find the API key under **Crawler > Settings** on the Algolia dashboard. This is a public, read-only key, so you can use it in merge requests.

## Lunr.js Search

Lunr.js is available as an alternative search backend for self-hosted GitLab Docs installations. Lunr search can also be used in offline or air-gapped environments. Lunr search requires an additional build step to create a search index.

Documentation review apps use Lunr search by default.

### Manually generate the Lunr search index

1. `yarn install`
1. `nanoc compile`
1. `make build-lunr-index`

Note that compiling the site will remove the index files, so if you recompile the site, you'll need to run the `make` command after to regenerate the required files.

## Toggle the search backend

Production always runs Algolia, but you can build the site with Lunr either locally or in a review app.

### Local environment

You can compile your local Nanoc site to use a specific search backend by setting the `ALGOLIA_SEARCH` environment variable.

- Use Algolia search: `export ALGOLIA_SEARCH="true"` (or leave this undefined)
- Use Lunr search: `export ALGOLIA_SEARCH="false"`
- If you do not set this variable before compiling, the build will default to Algolia.
