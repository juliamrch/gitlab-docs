#!/usr/bin/env node

/**
 * @file create_issues.js
 *
 * Issues created by this script are given hackathon-specific labels
 * and populated with descriptions of Vale warnings from the given CSV.
 *
 * Prerequistes:
 * 1. Install glab: https://gitlab.com/gitlab-org/cli
 * 2. Log in: glab auth login
 * 3. Run "yarn" in gitlab-docs to ensure node.js dependencies are up-to-date.
 *
 * Use the script:
 * 1. Create a spreadsheet of Vale issues using this template. Do not remove or change the headers.
 *    https://docs.google.com/spreadsheets/d/1ukGT-1H-Qvik9GwCU1n0oAH9vofvkKvlL3ga8PaCXjw/edit?usp=sharing
 * 2. Export the spreadsheet to a CSV, and remove spaces from the filename.
 * 3. The script requires three variables to run:
 *      - CSV_PATH: Path to your CSV file
 *      - REPO: URL of the destination project
 *      - MILESTONE: Milestone for the issue
 * 4. Prepend the above variables when calling the script, like this:
 *    CSV_PATH=Sheet1.csv REPO="https://gitlab.com/sselhorn/test-project" MILESTONE="15.9" ./scripts/create_issues.js
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

const LABELS =
  'Technical Writing,good for new contributors,Accepting merge requests,documentation,docs::improvement';

const TITLE_PREFIX = 'Fix Vale issues for';
const ISSUE_INTRO = `The following issues occurred when we ran a linting tool called Vale against this Markdown page in the GitLab documentation. The first number on each line indicates the line number where the error occurred.\n\n
To fix the issues, open a merge request for the markdown file, which you can find in the [/doc](https://gitlab.com/gitlab-org/gitlab/-/blob/master/doc) directory. When you open the MR, a bot will automatically ping the appropriate GitLab technical writer. They will work with you to merge the changes.\n\n
If you feel any of these warnings are incorrect, please create an issue with the tw-test label so we can improve our Vale tests. Thank you!`;

// Create GitLab issues from our CSV data.
const createIssues = (issues) => {
  issues.forEach((issue) => {
    const title = `${TITLE_PREFIX} ${issue.path}`;

    // Output the Vale warnings in a markdown table.
    let warningsTable = '\n\n| Line | Rule | Suggestion |\n| --- | --- | --- |\n';
    issue.warnings.forEach((w) => {
      warningsTable += `| ${w.line} | ${w.rule} | ${w.suggestion} |\n`;
    });
    const description = ISSUE_INTRO + warningsTable;

    // Use GitLab CLI to create a confidential issue.
    const command = `glab issue create -c -t "${title}" -d "${description}" -R ${REPO} -m ${MILESTONE} -l "${LABELS}"`;
    exec(command, (error, stdout) => {
      if (error) {
        console.error('Unable to create issues, exiting. Check error.log for details.');
        // Write errors to a log file.
        // Drop the command body since it's very long and obscures the actual error.
        fs.appendFile(
          'error.log',
          `[${new Date().toISOString()}]: ${error.toString().replace(command, '')}`,
          (fsError) => {
            if (fsError) throw fsError;
          },
        );
      } else {
        console.log(`Created new issue: ${stdout.replace('\n', '')}`);
      }
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
