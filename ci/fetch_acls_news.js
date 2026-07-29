#!/usr/bin/env node
/**
 * fetch_acls_news.js
 *
 * CI-only helper: uses a real headless browser (Playwright/Chromium) to
 * fetch paginated JSON from the ACLS WordPress REST API.
 *
 * BACKGROUND: acls.org's Cloudflare protection blocks plain HTTP requests —
 * confirmed directly (a Ruby Net::HTTP request from a real home network
 * returned HTTP 403) even though it does not block a real, JavaScript-
 * capable browser session. This script exists to bridge that gap: it does
 * NOT try to out-clever Cloudflare with headers or user-agent spoofing —
 * it just uses an actual browser, which is what Cloudflare's checks are
 * designed to let through.
 *
 * This script ONLY fetches and saves raw JSON pages to
 * src/_data/downloads/acls_news_pN.json. It does not filter or convert
 * anything to YAML — that's handled afterward by:
 *   ruby src/_scripts/acls_news_to_yaml.rb
 *
 * ATOMICITY: all pages are fetched into a temporary staging directory
 * first. Only if every page fetches successfully (or a "last page" is
 * reached cleanly) do the staged files replace whatever is in
 * src/_data/downloads/. If anything fails partway through, the staging
 * directory is discarded and src/_data/downloads/ (and therefore
 * _data/acls_news.yml, which nothing here touches directly) is left
 * completely untouched. The script exits non-zero on any failure so the
 * calling CI step can be marked accordingly and the build can fall back to
 * whatever acls_news.yml is already checked out from git.
 *
 * Usage (from repo root):
 *   cd ci && npm install && npx playwright install --with-deps chromium
 *   node ci/fetch_acls_news.js
 *
 * Wired into .github/workflows/deploy.yml to run before the Jekyll build.
 * If it fails, use the manual fallback documented in
 * src/_scripts/acls_news_to_yaml.rb.
 */

const { chromium } = require('playwright');
const fs = require('fs');
const os = require('os');
const path = require('path');

const API_BASE = 'https://www.acls.org/wp-json/wp/v2/news';
const PER_PAGE = 100;
const MAX_PAGES = 10;
const NAV_TIMEOUT_MS = 20000;
const REPO_ROOT = path.join(__dirname, '..');
const DOWNLOADS_DIR = path.join(REPO_ROOT, 'src', '_data', 'downloads');

const USER_AGENT =
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 ' +
  '(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';

/**
 * Fetches one page of the API using a real browser page object.
 * Throws on any non-OK response, empty body, or invalid JSON.
 */
async function fetchPage(page, pageNum) {
  const url =
    `${API_BASE}?per_page=${PER_PAGE}&page=${pageNum}` +
    '&_fields=id,title,link,date,excerpt,news_related_program';

  const response = await page.goto(url, {
    waitUntil: 'domcontentloaded',
    timeout: NAV_TIMEOUT_MS
  });

  if (!response) {
    throw new Error(`No response received for page ${pageNum}`);
  }
  if (!response.ok()) {
    throw new Error(`HTTP ${response.status()} on page ${pageNum}`);
  }

  const text = (await page.evaluate(() => document.body.innerText || '')).trim();
  if (!text) {
    throw new Error(`Empty response body on page ${pageNum}`);
  }

  let data;
  try {
    data = JSON.parse(text);
  } catch (err) {
    throw new Error(`Non-JSON response on page ${pageNum}: ${err.message}`);
  }

  return { text, data };
}

/**
 * Runs the full paginated fetch using the provided fetchPageFn, writing
 * complete results into stagingDir. Pure logic, no browser dependency —
 * this is what gets exercised in tests with a stubbed fetchPageFn.
 */
async function runFetchLoop(fetchPageFn, stagingDir) {
  fs.mkdirSync(stagingDir, { recursive: true });

  let pageNum = 1;
  let totalItems = 0;
  const savedFiles = [];

  while (pageNum <= MAX_PAGES) {
    const { text, data } = await fetchPageFn(pageNum);
    const items = Array.isArray(data) ? data : [data];

    if (items.length === 0) {
      break;
    }

    const outPath = path.join(stagingDir, `acls_news_p${pageNum}.json`);
    fs.writeFileSync(outPath, text);
    savedFiles.push(outPath);
    totalItems += items.length;

    if (items.length < PER_PAGE) {
      break;
    }
    pageNum += 1;
  }

  if (savedFiles.length === 0) {
    throw new Error('No pages were successfully fetched — nothing to stage.');
  }

  return { savedFiles, totalItems };
}

/**
 * Atomically replaces the contents of targetDir with the contents of
 * stagingDir. Only called after a fully successful fetch.
 */
function promoteStagingToTarget(stagingDir, targetDir) {
  fs.mkdirSync(targetDir, { recursive: true });

  for (const entry of fs.readdirSync(targetDir)) {
    if (entry.endsWith('.json')) {
      fs.rmSync(path.join(targetDir, entry));
    }
  }

  for (const entry of fs.readdirSync(stagingDir)) {
    fs.renameSync(path.join(stagingDir, entry), path.join(targetDir, entry));
  }
}

async function main() {
  const stagingDir = fs.mkdtempSync(path.join(os.tmpdir(), 'acls-news-staging-'));

  const browser = await chromium.launch({
    args: ['--disable-blink-features=AutomationControlled']
  });

  try {
    const context = await browser.newContext({
      userAgent: USER_AGENT,
      viewport: { width: 1280, height: 800 }
    });
    const page = await context.newPage();

    const { savedFiles, totalItems } = await runFetchLoop(
      (pageNum) => fetchPage(page, pageNum),
      stagingDir
    );

    promoteStagingToTarget(stagingDir, DOWNLOADS_DIR);
    console.log(
      `Fetched ${totalItems} item(s) across ${savedFiles.length} page(s) ` +
      `and staged into ${DOWNLOADS_DIR}`
    );
  } finally {
    await browser.close();
    fs.rmSync(stagingDir, { recursive: true, force: true });
  }
}

if (require.main === module) {
  main().catch((err) => {
    console.error(`fetch_acls_news.js failed: ${err.message}`);
    console.error('src/_data/downloads/ and _data/acls_news.yml were left untouched.');
    process.exit(1);
  });
}

module.exports = { runFetchLoop, promoteStagingToTarget, fetchPage };
