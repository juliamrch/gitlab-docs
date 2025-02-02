#!/usr/bin/env node

/**
 * @file pages_not_in_nav.js
 * Generates a report of pages which are not included in navigation.yaml.
 */

/* eslint-disable no-console */

const fs = require('fs');
const glob = require('glob');
const yaml = require('js-yaml');

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
    isIgnored: contents.includes('ignore_in_report'),
  };
};

// Loop through each data source's markdown files.
const infoPrefix = '\x1b[32mINFO:\x1b[0m';
const warnPrefix = '\x1b[33mWARN:\x1b[0m';
const errorPrefix = '\x1b[31mERROR:\x1b[0m';
const italicsText = '\u001b[3m';
const resetText = '\x1b[0m';

dataSources.forEach((source) => {
  glob.sync(`${source.content_dir}/**/*.md`).forEach((filename) => {
    try {
      const pageData = getPageData(filename);
      if (pageData.isRedirect) {
        if (process.env.VERBOSE) {
          console.info(`${infoPrefix} skipping redirected page: ${filename}.`);
        }
        return;
      }
      if (pageData.isDeprecated) {
        if (process.env.VERBOSE) {
          console.info(`${infoPrefix} skipping deprecated page: ${filename}.`);
        }
        return;
      }
      if (pageData.isIgnored) {
        if (process.env.VERBOSE) {
          console.info(`${infoPrefix} skipping ignored page:    ${filename}.`);
        }
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
        // Exclude sections that are intentionally not in the nav. Don't add a leading `/` if path is at the root of the site.
        // For example, `ee/development/` and not `/ee/development/`.
        !path.includes('/architecture/') &&
        !path.match(/\/user\/application_security\/dast\/browser\/checks\/\w+/) &&
        !path.match(/\/user\/application_security\/api_security_testing\/checks\/\w+/) &&
        !path.includes('/legal/') &&
        !path.includes('/drawers/') &&
        !path.includes('/adr/') &&
        !path.includes('charts/development/') &&
        !path.includes('ee/development/') &&
        !path.includes('omnibus/development/')
      ) {
        console.warn(
          `${warnPrefix} page at ${italicsText}https://docs.gitlab.com/${path}${resetText} is missing from global navigation!`,
        );
      }
    } catch (error) {
      console.error(
        `${errorPrefix} skipping '${filename}' because of error: '${error}'\nFix '${filename}' and try again.\n`,
      );
    }
  });
});
