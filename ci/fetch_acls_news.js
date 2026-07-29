#!/usr/bin/env node
/**
 * fetch_acls_news.js
 *
 * Fetches the 10 most recent items from ACLS's own "China Studies" news
 * facet directly via a real headless browser (Playwright/Chromium), and
 * writes the results straight to src/_data/acls_news.yml in the exact
 * format the Jekyll site expects.
 *
 * SCOPE: only the first page (10 most recent items) is fetched. The
 * Mapping Project's news section is meant as a recent-highlights feed, not
 * a full archive — a link at the bottom of the site's news page points to
 * ACLS's own facet (see src/news.html) for anyone who wants the complete
 * history. This deliberately keeps the script simple: no pagination, no
 * "click next and wait" handling, no page-count safety cap.
 *
 * WHY THIS APPROACH (rather than the WordPress REST API):
 *   - acls.org's Cloudflare protection blocks plain HTTP requests, so a
 *     real browser is required regardless — confirmed directly (a Ruby
 *     Net::HTTP request got HTTP 403 even from a home network).
 *   - The REST API doesn't reliably expose or filter by the
 *     news_related_program taxonomy: testing showed the field never
 *     appears in API responses, and the news_related_program=25469 query
 *     parameter is silently ignored, returning unrelated posts.
 *   - The keyword-based fallback filter previously used to guess which
 *     items were "China Studies" repeatedly produced false positives —
 *     e.g. matching "Luce/ACLS Fellow in Religion" and "...Dissertation
 *     Fellowships in American Art" just because they mention "Luce/ACLS",
 *     a brand name shared by several unrelated ACLS programs.
 *   - ACLS's own site has a faceted search (FacetWP) that filters news by
 *     program, editorially maintained by ACLS staff. Navigating to
 *         https://www.acls.org/acls-news/?_news_related_program=25469
 *     and reading the rendered results is authoritative — no guessing.
 *     (Fetching this URL with a plain, non-JS request returns the generic
 *     unfiltered news list — a cache layer appears to ignore the query
 *     string for non-browser requests — which is why a real browser
 *     session is required here too, not just for the Cloudflare check.)
 *
 * This script writes YAML directly (via the `yaml` npm package), so no
 * separate Ruby conversion step is needed in CI.
 *
 * SAFETY: the output file is only written after the page is read
 * successfully, and even then via a temp-file-plus-rename so a crash
 * mid-write can't corrupt anything. Any failure — network, layout change,
 * timeout — leaves _data/acls_news.yml completely untouched, and the
 * script exits non-zero so CI can fall back to whatever is already
 * committed.
 *
 * Usage (from repo root):
 *   cd ci && npm install && npx playwright install --with-deps chromium
 *   node ci/fetch_acls_news.js
 *
 * If this breaks (e.g. ACLS redesigns the news page), fall back to the
 * manual, keyword-based method documented in
 * src/_scripts/acls_news_to_yaml.rb. It's less accurate but self-contained.
 */

const { chromium } = require('playwright');
const YAML = require('yaml');
const fs = require('fs');
const path = require('path');

const START_URL = 'https://www.acls.org/acls-news/?_news_related_program=25469';
const NAV_TIMEOUT_MS = 30000;
const REPO_ROOT = path.join(__dirname, '..');
const DATA_FILE = path.join(REPO_ROOT, 'src', '_data', 'acls_news.yml');

const USER_AGENT =
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 ' +
  '(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';

/** Extracts {title, url, date, excerpt} for every article on the current page. */
async function extractArticles(page) {
  return page.$$eval('article.teaser', (nodes) =>
    nodes.map((el) => {
      const titleLink = el.querySelector('.teaser__title a');
      return {
        title: titleLink ? titleLink.textContent.trim() : '',
        url: titleLink ? titleLink.href : '',
        date: el.querySelector('.teaser__date')?.textContent.trim() || '',
        excerpt: el.querySelector('.teaser__summary')?.textContent.trim() || ''
      };
    })
  );
}

/** Dedupes by URL and sorts newest-first. */
function sortAndDedupe(items) {
  const seen = new Set();
  const deduped = items.filter((item) => {
    if (!item.url || seen.has(item.url)) return false;
    seen.add(item.url);
    return true;
  });

  deduped.sort((a, b) => new Date(b.date) - new Date(a.date));
  return deduped;
}

async function main() {
  const browser = await chromium.launch({
    args: ['--disable-blink-features=AutomationControlled']
  });

  try {
    const context = await browser.newContext({
      userAgent: USER_AGENT,
      viewport: { width: 1280, height: 800 }
    });
    const page = await context.newPage();

    await page.goto(START_URL, { waitUntil: 'domcontentloaded', timeout: NAV_TIMEOUT_MS });
    await page.waitForSelector('article.teaser', { timeout: NAV_TIMEOUT_MS });

    const items = await extractArticles(page);
    if (items.length === 0) {
      throw new Error('No China Studies items found — the facet page layout may have changed.');
    }

    const deduped = sortAndDedupe(items);
    const yamlText = YAML.stringify({ items: deduped });

    const tmpFile = `${DATA_FILE}.tmp-${process.pid}`;
    fs.writeFileSync(tmpFile, yamlText);
    fs.renameSync(tmpFile, DATA_FILE);

    console.log(`Fetched ${deduped.length} China Studies item(s) and wrote ${DATA_FILE}`);
  } finally {
    await browser.close();
  }
}

if (require.main === module) {
  main().catch((err) => {
    console.error(`fetch_acls_news.js failed: ${err.message}`);
    console.error('_data/acls_news.yml was left untouched.');
    process.exit(1);
  });
}

module.exports = { extractArticles, sortAndDedupe };
