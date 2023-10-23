# Docs site analytics

The Technical Writing team tracks website usage with Google Analytics.

GitLab team members can browse Google Analytics data on [this dashboard](https://lookerstudio.google.com/reporting/d6af7a2b-2aaa-4f30-8742-811e62777c93/page/p_ihbvblyl2c).

This dashboard includes data from [Google Programmable Search](search.md), such as
popular search queries and the search result click rate.

For help with analytics tooling, create an issue for the [GitLab Marketing Strategy & Analytics
team](https://about.gitlab.com/handbook/marketing/strategy-performance/).

## Other scripts

* Bizible: Used by the GitLab marketing ops team to track the customer journey across GitLab websites. Loaded from [analytics.html](../layouts/analytics.html).
* LinkedIn: Used by the GitLab brand marketing team. Loaded from [analytics.html](../layouts/analytics.html).
* Marketo: Used by the GitLab marketing ops team to track web visits. Loaded from [analytics.html](../layouts/analytics.html).
* OneTrust: Provides privacy-related cookie settings. Loaded from [head.html](../layouts/head.html).
* [GitLab product analytics](https://docs.gitlab.com/ee/user/product_analytics/): Experimental. Currently this only tracks page views. GitLab team members can view data on the [analytics dashboard](https://gitlab.com/gitlab-org/gitlab-docs/-/analytics/dashboards/behavior?date_range_option=last_7_days). Loaded from [head.html](../layouts/head.html).

## Implementation

Analytics scripts are only included on the production domain and are excluded from
archived or self-hosted versions. Any new scripts should be loaded from the
[analytics.html](../layouts/analytics.html) template in order to maintain the
same conditional loading rules.

To test analytics scripts locally, compile Nanoc with the production flag:

```shell
NANOC_ENV="production" make compile
```
