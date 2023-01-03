#!/usr/bin/env node

/**
 * @file create_issues.js
 *
 * This script takes a CSV file of Vale issues and uses the
 * Doc_cleanup.md template to create issues for contributors.
 *
 * An issue is created for each markdown file in the CSV. For example:
 * https://gitlab.com/gitlab-org/gitlab/-/issues/386506
 *
 * The Doc_cleanup.md template is here:
 * https://gitlab.com/gitlab-org/gitlab/-/blob/master/.gitlab/issue_templates/Doc_cleanup.md
 * This template has labels associated with it.
 * These labels are assigned to the issues.
 *
 * An example sheet (that you can export to CSV file) is here:
 * https://docs.google.com/spreadsheets/d/1ukGT-1H-Qvik9GwCU1n0oAH9vofvkKvlL3ga8PaCXjw/edit?usp=sharing
 *
 *
 * Prerequistes:
 * 1. Install glab: https://gitlab.com/gitlab-org/cli
 * 2. Log in: glab auth login
 * 3. Run "yarn" in gitlab-docs to ensure node.js dependencies are up-to-date.
 *
 * Use the script:
 * 1. Create a spreadsheet of Vale issues by using this template. Do not remove or change the headers.
 *    https://docs.google.com/spreadsheets/d/1ukGT-1H-Qvik9GwCU1n0oAH9vofvkKvlL3ga8PaCXjw/edit?usp=sharing
 * 2. Export the spreadsheet to a CSV, and remove spaces from the filename.
 * 3. The script requires three variables to run:
 *      - CSV_PATH: Path to your CSV file
 *      - REPO: URL of the destination project
 *      - MILESTONE: Milestone for the issue (ID or name)
 * 4. Prepend the above variables when calling the script, like this:
 *    CSV_PATH="Sheet1.csv" REPO="https://gitlab.com/sselhorn/test-project" MILESTONE="15.9" ./scripts/create_issues.js
 *
 *    The Backlog milestone in the main gitlab repo is 490705.
 *
 * 5. Run the command from the root of the gitlab-docs project.
 */

/* eslint-disable no-console */
/* eslint-disable import/no-extraneous-dependencies */

const fs = require('fs');
const { exec } = require('child_process');
const csv = require('fast-csv');

const { CSV_PATH, REPO, MILESTONE } = process.env;
if (!CSV_PATH || !REPO || !MILESTONE) {
  console.log('Missing a required parameter, exiting.');
  process.exit();
}

const TITLE_PREFIX = 'Fix Vale issues for';
const TEMPLATE_PATH = '../gitlab/.gitlab/issue_templates/Doc_cleanup.md';
const DOCS_PATH = 'https://gitlab.com/gitlab-org/gitlab/-/tree/master/doc/';

// Load our issue template, and create a GitLab issue for each set of warnings.
const createIssues = (issues) => {
  fs.readFile(TEMPLATE_PATH, 'utf8', (err, template) => {
    if (err) {
      console.log(`Error reading template: ${err}`);
      process.exit();
    }

    issues.forEach((issue) => {
      const title = `${TITLE_PREFIX} ${issue.path}`;

      // Format the Vale warnings in a markdown table.
      let warningsTable = '\n\n| Line | Rule | Suggestion |\n| --- | --- | --- |\n';
      issue.warnings.forEach((w) => {
        warningsTable += `| ${w.line} | ${w.rule} | ${w.suggestion} |\n`;
      });

      // Assemble the issue description.
      const outro = `In the file [${issue.path}](${
        DOCS_PATH + issue.path
      }), update the following lines to address the listed issue.`;

      let description = template + outro + warningsTable;
      // Replace quotes and backticks so we can pass the description as a parameter.
      description = description.replace(/"/g, '\\"').replace(/`/g, '\\`');

      // Use GitLab CLI to create a confidential issue.
      const command = `glab issue create -c -t "${title}" -d "${description}" -R ${REPO} -m ${MILESTONE}`;
      exec(command, (error, stdout) => {
        if (error) {
          console.error('Unable to create issues, exiting. Check error.log for details.');
          fs.appendFile(
            'error.log',
            `[${new Date().toISOString()}]: ${error.toString()}`,
            (fsError) => {
              if (fsError) throw fsError;
            },
          );
        } else {
          console.log(`Created new issue: ${stdout.replace('\n', '')}`);
        }
      });
    });
  });
};

// Read the CSV and group Vale warnings by path.
const issues = [];
fs.createReadStream(CSV_PATH)
  .pipe(csv.parse({ headers: true }))
  .on('error', (error) => console.error(error))
  .on('data', (row) => {
    const warning = {
      line: row.Line,
      rule: row.Rule,
      suggestion: row.Suggestion,
    };
    const index = issues.findIndex((x) => x.path === row.Path);

    if (index >= 0) {
      issues[index].warnings.push(warning);
    } else {
      issues.push({ path: row.Path, warnings: [warning] });
    }
  })
  .on('end', () => createIssues(issues));
