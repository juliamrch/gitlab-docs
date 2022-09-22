#!/usr/bin/env node

/**
 * @file preindex.js
 * Creates data files required for Lunr search.
 *
 * This script creates two JSON files:
 *   - lunr-index.json: A serialized search index.
 *   - lunr-map.json: Maps index item IDs to their human-readable titles.
 *
 * @see https://lunrjs.com/guides/index_prebuilding.html
 */

/* eslint-disable no-console */

const fs = require('fs');
const lunr = require('lunr');
const cheerio = require('cheerio');
const glob = require('glob');

const htmlSrc = 'public/';
const outputDir = `${htmlSrc}assets/javascripts`;

/**
 * Find all HTML files within a given path,
 * then execute a callback function to build the index.
 */
const buildIndex = (path, callback) => {
  glob(`${path}/**/*.html`, callback);
};

/**
 * Extracts text from a given HTML element.
 *
 * @param {cheerio} $
 *   A Cheerio page object
 * @param {String} element
 *   An HTML element to search for
 *
 * @return {String}
 *   All text contained within the given element
 */
const getText = ($, element) => {
  const headingText = [];
  $(element)
    .toArray()
    .forEach((el) => {
      headingText.push($(el).text().replace('\n', ''));
    });
  return headingText.join(' ');
};

/**
 * Build the index and output files.
 */
buildIndex(htmlSrc, (err, filenames) => {
  if (err) {
    console.error(err);
  }

  // Create an array of objects containing each page's text content.
  const pages = [];
  Object.keys(filenames).forEach((key) => {
    const filename = filenames[key];
    const $ = cheerio.load(fs.readFileSync(filename));
    const title = getText($, 'h1');

    if (title.length) {
      pages.push({
        id: filename.slice(htmlSrc.length),
        h1: title.trim(),
        h2: getText($, 'h2'),
        h3: getText($, 'h3'),
      });
    }
  });

  // Build the serialized Lunr search index.
  const idx = lunr((e) => {
    e.ref('id');
    e.field('h1', { boost: 10 });
    e.field('h2', { boost: 5 });
    e.field('h3', { boost: 2 });
    pages.forEach((doc) => {
      e.add(doc);
    }, e);
  });

  // Write the index file.
  fs.writeFile(`${outputDir}/lunr-index.json`, JSON.stringify(idx), (fsErr) => {
    if (fsErr) {
      console.error(fsErr);
    }
  });

  // Write the map file.
  // We can drop h2s and h3s from this since we don't display those in results.
  const pageMap = pages.map(({ h2, h3, ...rest }) => {
    return rest;
  });
  fs.writeFile(`${outputDir}/lunr-map.json`, JSON.stringify(pageMap), (fsErr) => {
    if (fsErr) {
      console.error(fsErr);
    }
  });
});
