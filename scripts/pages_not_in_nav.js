#!/usr/bin/env node

/**
 * @file pages_not_in_nav.js
 * Generates a report of pages which are not included in navigation.yaml.
 */

/* eslint-disable no-console */

const fs = require('fs');
const glob = require('glob');
const yaml = require('js-yaml');
const fm = require('front-matter');

// Load site data sources from nanoc config.
const nanocConfig = yaml.load(fs.readFileSync('nanoc.yaml', 'utf8'));
const dataSources = nanocConfig.data_sources.filter((source) => source.items_root !== '/');

// Load the global navigation data file.
const navYaml = yaml.load(fs.readFileSync('content/_data/navigation.yaml', 'utf8'));
const nav = JSON.stringify(navYaml);

// Read the markdown file and extract the fields we need.
const getPageData = (filename) => {
  const contents = fs.readFileSync(filename, 'utf-8');
  const title = contents
    .split('\n')
    .filter((line) => line.startsWith('# '))
    .toString()
    .toLowerCase();

  return {
    filename,
    isRedirect: contents.includes('redirect_to'),
    isDeprecated: title.includes('(deprecated)') || title.includes('(removed)'),
    stage: fm(contents).attributes.stage,
    group: fm(contents).attributes.group,
  };
};

// Loop through each data source's markdown files.
const lostPages = [];
dataSources.forEach((source) => {
  glob.sync(`${source.content_dir}/**/*.md`).forEach((filename) => {
    const pageData = getPageData(filename);
    if (pageData.isRedirect || pageData.isDeprecated) {
      return;
    }

    // Convert the markdown filepath into a string that matches the URL path on the website.
    const path =
      source.items_root.replaceAll('/', '') +
      filename
        .replace(source.content_dir, '')
        .replace(source, '')
        .replace('index.md', '')
        .replace('.md', '.html');

    if (
      // Include pages that are not in the nav.
      !nav.includes(path) &&
      // Exclude sections that are intentionally not in the nav.
      !path.includes('/architecture/blueprints') &&
      !path.includes('/user/application_security/dast/browser/checks/') &&
      !path.includes('/legal/') &&
      !path.includes('/drawers/') &&
      !path.includes('/adr/')
    ) {
      lostPages.push({
        url: `https://docs.gitlab.com/${path}`,
        stage: pageData.stage,
        group: pageData.group,
      });
    }
  });
});

// Return results as JSON.
console.log(JSON.stringify(lostPages));
