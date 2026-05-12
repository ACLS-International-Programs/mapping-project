---
layout: single
title: "Database Workflows"
permalink: /databaseworkflows-draft/
toc: false
classes: wide article-page
sitemap: false
---

<style>
/* ── Progress-aware sticky TOC ── */
#toc-rail {
  position: fixed;
  top: 50%;
  right: 18px;
  transform: translateY(-50%);
  z-index: 999;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0;
}
#toc-rail .toc-track {
  position: absolute;
  top: 0;
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 2px;
  background: #e0e0e0;
  border-radius: 2px;
  z-index: 0;
}
#toc-rail .toc-progress {
  position: absolute;
  top: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 2px;
  background: #2B3AA8;
  border-radius: 2px;
  height: 0%;
  z-index: 1;
  transition: height 0.15s ease;
}
.toc-dot-wrap {
  position: relative;
  z-index: 2;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  padding: 5px 0;
}
.toc-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #ccc;
  border: 2px solid #fff;
  box-shadow: 0 0 0 1px #ccc;
  cursor: pointer;
  transition: background 0.2s, transform 0.2s, box-shadow 0.2s;
  display: block;
}
.toc-dot.h2-dot {
  width: 10px;
  height: 10px;
}
.toc-dot.active {
  background: #2B3AA8;
  box-shadow: 0 0 0 1px #2B3AA8;
  transform: scale(1.3);
}
.toc-tooltip {
  position: absolute;
  right: 20px;
  background: #1a1a1a;
  color: #fff;
  font-family: 'IBM Plex Mono', monospace;
  font-size: 0.7rem;
  letter-spacing: 0.04em;
  padding: 4px 10px;
  border-radius: 3px;
  white-space: nowrap;
  pointer-events: none;
  opacity: 0;
  transition: opacity 0.15s;
  z-index: 10;
}
.toc-dot-wrap:hover .toc-tooltip {
  opacity: 1;
}
</style>

<div id="toc-rail">
  <div class="toc-track"></div>
  <div class="toc-progress" id="toc-progress-bar"></div>
  <div class="toc-dot-wrap"><a class="toc-dot h2-dot" data-target="building-a-digital-archive-for-china-studies"></a><span class="toc-tooltip">Introduction</span></div>
  <div class="toc-dot-wrap"><a class="toc-dot h2-dot" data-target="phase-1-document-preparation-and-advanced-ocr"></a><span class="toc-tooltip">Phase 1: Document Prep &amp; OCR</span></div>
  <div class="toc-dot-wrap"><a class="toc-dot" data-target="step-11-file-naming-conventions"></a><span class="toc-tooltip">1.1 File Naming</span></div>
  <div class="toc-dot-wrap"><a class="toc-dot" data-target="step-12-image-pre-processing"></a><span class="toc-tooltip">1.2 Image Pre-Processing</span></div>
  <div class="toc-dot-wrap"><a class="toc-dot" data-target="step-13-running-ocr-on-chinese-documents"></a><span class="toc-tooltip">1.3 Running OCR</span></div>
  <div class="toc-dot-wrap"><a class="toc-dot" data-target="step-14-the-character-simplification-problem"></a><span class="toc-tooltip">1.4 Character Simplification</span></div>
  <div class="toc-dot-wrap"><a class="toc-dot h2-dot" data-target="phase-2-ai-assisted-metadata-and-taxonomy-generation"></a><span class="toc-tooltip">Phase 2: AI Metadata</span></div>
  <div class="toc-dot-wrap"><a class="toc-dot" data-target="step-21-extracting-metadata-with-an-llm"></a><span class="toc-tooltip">2.1 Metadata Extraction</span></div>
  <div class="toc-dot-wrap"><a class="toc-dot" data-target="step-22-building-a-taxonomy-through-ai-subject-tagging"></a><span class="toc-tooltip">2.2 AI Subject Tagging</span></div>
  <div class="toc-dot-wrap"><a class="toc-dot h2-dot" data-target="phase-3-setting-up-omeka-classic"></a><span class="toc-tooltip">Phase 3: Omeka Setup</span></div>
  <div class="toc-dot-wrap"><a class="toc-dot" data-target="step-31-installation"></a><span class="toc-tooltip">3.1 Installation</span></div>
  <div class="toc-dot-wrap"><a class="toc-dot" data-target="step-32-installing-core-plugins"></a><span class="toc-tooltip">3.2 Core Plugins</span></div>
  <div class="toc-dot-wrap"><a class="toc-dot h2-dot" data-target="phase-4-metadata-schema-and-bulk-import"></a><span class="toc-tooltip">Phase 4: Bulk Import</span></div>
  <div class="toc-dot-wrap"><a class="toc-dot" data-target="step-41-structuring-your-csv"></a><span class="toc-tooltip">4.1 CSV Structure</span></div>
  <div class="toc-dot-wrap"><a class="toc-dot" data-target="step-42-running-the-import"></a><span class="toc-tooltip">4.2 Running Import</span></div>
  <div class="toc-dot-wrap"><a class="toc-dot h2-dot" data-target="phase-5-configuring-chinese-full-text-search"></a><span class="toc-tooltip">Phase 5: Full-Text Search</span></div>
  <div class="toc-dot-wrap"><a class="toc-dot" data-target="step-51-apache-solr-with-the-smart-chinese-analyzer"></a><span class="toc-tooltip">5.1 Apache Solr</span></div>
  <div class="toc-dot-wrap"><a class="toc-dot" data-target="step-52-advanced-search-as-a-fallback"></a><span class="toc-tooltip">5.2 Advanced Search</span></div>
  <div class="toc-dot-wrap"><a class="toc-dot h2-dot" data-target="summary-the-complete-workflow"></a><span class="toc-tooltip">Summary</span></div>
  <div class="toc-dot-wrap"><a class="toc-dot h2-dot" data-target="references"></a><span class="toc-tooltip">References</span></div>
</div>

<script>
(function() {
  var dots = document.querySelectorAll('.toc-dot');
  var progressBar = document.getElementById('toc-progress-bar');
  var rail = document.getElementById('toc-rail');

  // Build section map: dot index -> heading element
  var sections = [];
  dots.forEach(function(dot, i) {
    var id = dot.getAttribute('data-target');
    var el = document.getElementById(id);
    if (el) sections.push({ dot: dot, el: el, index: i });
    dot.addEventListener('click', function() {
      if (el) {
        el.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
    });
  });

  function update() {
    var scrollTop = window.scrollY || document.documentElement.scrollTop;
    var docHeight = document.documentElement.scrollHeight - window.innerHeight;
    var progress = docHeight > 0 ? (scrollTop / docHeight) * 100 : 0;
    if (progressBar) progressBar.style.height = progress + '%';

    // Find active section
    var active = 0;
    for (var i = 0; i < sections.length; i++) {
      var rect = sections[i].el.getBoundingClientRect();
      if (rect.top <= 120) active = i;
    }
    dots.forEach(function(d) { d.classList.remove('active'); });
    if (sections[active]) sections[active].dot.classList.add('active');
  }

  window.addEventListener('scroll', update, { passive: true });
  update();
})();
</script>

## Building a Digital Archive for China Studies

This tutorial provides a comprehensive, step-by-step workflow for researchers in China Studies who wish to build a fully searchable digital archive from their own scanned historical documents. The workflow draws on the infrastructure of the [Maoist Legacy Database](https://www.maoistlegacy.de){:target="_blank"} [1] and the [Grassroots Chinese History Archive](https://grassrootschinesehistory.ca){:target="_blank"} [2], both of which successfully digitized thousands of grassroots and state documents from the post-Mao and Cultural Revolution eras.

By following this guide, you will learn how to organize your scanned files, extract Chinese text using Optical Character Recognition (OCR), leverage Large Language Models (LLMs) to automate metadata extraction, set up an Omeka Classic repository, and implement a robust full-text search engine capable of handling Chinese characters.



## Phase 1: Document Preparation and Advanced OCR

The foundation of any digital archive is the quality and organization of its source files. Assuming you already possess scanned copies of historical documents — such as archival dossiers, internal reports, local gazetteers, or factory records — the first step is to ensure these files are properly named and processed for text extraction before any database work begins.

### Step 1.1: File Naming Conventions

Establish a consistent, machine-readable file naming structure before importing anything into a database. A best practice is to use a combination of the document date (in `YYYY-MM-DD` format) and a unique identifier or brief descriptive slug. Avoid using spaces, Chinese characters, or special characters in filenames, as these can cause errors in command-line tools and web servers.

The recommended convention is:

```text
YYYY-MM-DD_DescriptiveSlug_SequenceNumber.pdf
```

For example, a document from November 2, 1983, issued by the Central Committee General Office (中共中央办公厅), might be named:

```text
1983-11-02_Zhongbanfa_7.pdf
```

If you have a large collection, organize your files into a folder hierarchy that mirrors your planned archive structure. A reasonable approach is to organize by year at the top level, then by issuing authority or collection:

```text
/archive
  /1966
    /zhongfa
      1966-05-16_Zhongfa_267.pdf
      1966-08-08_Zhongfa_301.pdf
  /1967
    /hongweibing
      1967-03-11_Hongweibing_Bulletin_12.pdf
```

<div class="workflow-note">
<strong>Tip:</strong> If you are working with a large collection, consider using a spreadsheet to track your files as you rename them. A simple three-column sheet with columns for the original filename, the new filename, and any notes will save you considerable time when you later build your CSV import file.
</div>

### Step 1.2: Image Pre-Processing

Before running OCR, scanned images must be optimized. Poor scan quality is the single leading cause of OCR failure on Chinese historical documents. The following steps should be applied to all scans before processing.

**Resolution:** Ensure all scans are at minimum 300 DPI. For documents with small print, dense characters, or significant fading — common in mimeographed internal circulars from the 1950s–1970s — 400 or 600 DPI is strongly recommended [3].

**Deskewing:** Pages that were scanned at even a slight angle (as little as 2°) will produce significantly more OCR errors. Most scanning software includes an auto-deskew option; if yours does not, the free tool [ImageMagick](https://imagemagick.org) can batch-correct skew with the following command:

```bash
mogrify -deskew 40% *.tiff
```

**Contrast Enhancement:** Increase contrast to sharpen the boundary between ink and paper. For faded documents, converting to grayscale first and then applying a threshold (converting to pure black and white) often produces better results than working with the full color scan.

**Batch Processing with ImageMagick:** To pre-process an entire folder of TIFF scans at once — converting to grayscale, deskewing, and increasing contrast — you can run:

```bash
mogrify -colorspace Gray -deskew 40% -contrast-stretch 5%x5% *.tiff
```

### Step 1.3: Running OCR on Chinese Documents

To make your documents full-text searchable, the images must be converted into searchable PDFs. The output is a PDF that contains the original scanned image of the document, but with an invisible layer of recognized text embedded behind it. This text layer is what search engines index.

For Chinese historical documents, standard OCR tools often struggle with the mixture of traditional and simplified characters, vertical text layouts, and poor print quality. Three tools are recommended, depending on your budget and technical comfort level:

| Tool | Type | Best For |
|------|------|----------|
| **ABBYY FineReader** | Commercial | Complex layouts, highest accuracy, both script types [4] |
| **PaddleOCR** | Open-source (GPU) | Batch processing; often outperforms Tesseract on Chinese [5] |
| **OCRmyPDF** | Open-source (CLI) | Batch-converting image folders to searchable PDFs [6] |

**Using OCRmyPDF** is the most accessible option for researchers without a commercial license. Once installed, you can process a single document with both Simplified and Traditional Chinese language packs:

```bash
ocrmypdf -l chi_sim+chi_tra input.pdf output_searchable.pdf
```

To batch-process an entire folder of PDFs, saving each output to a new folder:

```bash
for f in /archive/1966/zhongfa/*.pdf; do
  ocrmypdf -l chi_sim+chi_tra "$f" "/archive/1966/zhongfa/ocr/$(basename "$f")";
done
```

<div class="workflow-note">
<strong>What does <code>-l chi_sim+chi_tra</code> mean?</strong> This flag tells the Tesseract OCR engine (which OCRmyPDF uses under the hood) to use both the Simplified Chinese (<code>chi_sim</code>) and Traditional Chinese (<code>chi_tra</code>) language models simultaneously. For documents that mix both script types — common in the early PRC period — using both models together significantly improves accuracy.
</div>

### Step 1.4: The Character Simplification Problem

A critical issue specific to Chinese archival research: documents from the 1950s–1970s may use the **rescinded second-round simplified characters** (二简字, *Èr jiǎn zì*) promulgated in 1977 and officially withdrawn in 1986, or may mix traditional and simplified scripts within the same document. Standard search engine dictionaries cannot handle these variants, meaning documents containing these characters may be invisible to keyword searches.

As noted by the Maoist Legacy project team, the recommended workaround is to leave the original scanned image intact in the PDF, but manually correct the hidden OCR text layer to use standard **first-round simplified characters** (一简字) [7]. This ensures the document is discoverable via standard keyboard input without altering the visual record of the original source.

<div class="workflow-warning">
<strong>Warning:</strong> This correction step is labor-intensive and requires a researcher with strong command of both traditional and simplified Chinese. It is best treated as an ongoing curation task rather than a prerequisite for initial publication. Publish your archive first, then correct the OCR layer incrementally as resources allow.
</div>

---

## Phase 2: AI-Assisted Metadata and Taxonomy Generation

Manually reading thousands of documents to extract titles, dates, authors, and subjects is the most labor-intensive part of building an archive. Recent advancements in Large Language Models (LLMs) like GPT-4o and Claude 3.5 Sonnet offer a powerful way to automate this data entry, reducing what might take weeks of manual cataloguing to a matter of hours [8].

### Step 2.1: Extracting Metadata with an LLM

Once your documents have been OCR'd, you can use a Python script to pass the raw text of each document to an LLM via API. By crafting a strict prompt, you can instruct the LLM to read the Chinese text and output structured JSON data containing the document's metadata [9].

The following Python script demonstrates how to loop through a folder of searchable PDFs, extract the text layer from each one, send it to the OpenAI API, and save the returned metadata to a JSON file:

```python
import os
import json
import pdfplumber
from openai import OpenAI

client = OpenAI()  # uses OPENAI_API_KEY environment variable

PROMPT = """You are an expert archivist of modern Chinese history.
Read the following OCR text from a historical Chinese government document.
Extract the following fields and return them as a JSON object only, with no other text:
- title: the formal document title in Chinese
- date: the document date in YYYY-MM-DD format (use null if not found)
- issuing_authority: the government organ or committee that issued the document
- summary: a 2-sentence English summary of the document's contents
- tags: a list of 3-5 thematic subject tags in English (e.g. "Land Reform", "Sent-down Youth")
"""

def extract_text_from_pdf(pdf_path):
    with pdfplumber.open(pdf_path) as pdf:
        return "\n".join(page.extract_text() or "" for page in pdf.pages)

results = []
pdf_folder = "/archive/1966/zhongfa/ocr"

for filename in os.listdir(pdf_folder):
    if not filename.endswith(".pdf"):
        continue
    pdf_path = os.path.join(pdf_folder, filename)
    text = extract_text_from_pdf(pdf_path)
    if not text.strip():
        print(f"Skipping {filename}: no text layer found")
        continue
    response = client.chat.completions.create(
        model="gpt-4o",
        temperature=0,
        messages=[
            {"role": "system", "content": PROMPT},
            {"role": "user", "content": text[:4000]}  # limit to first 4000 chars
        ]
    )
    metadata = json.loads(response.choices[0].message.content)
    metadata["filename"] = filename
    results.append(metadata)
    print(f"Processed: {filename}")

with open("metadata_output.json", "w", encoding="utf-8") as f:
    json.dump(results, f, ensure_ascii=False, indent=2)

print(f"Done. {len(results)} records saved to metadata_output.json")
```

<div class="workflow-note">
<strong>Note on token limits:</strong> The script above truncates each document to the first 4,000 characters. For most government documents, the title, date, and issuing authority appear in the first paragraph, so this is usually sufficient. For longer documents where the summary requires reading further, increase this limit to 8,000 or 16,000 characters depending on your model's context window.
</div>

### Step 2.2: Building a Taxonomy Through AI Subject Tagging

The `tags` field in the prompt above is the foundation of your subject taxonomy. Over a collection of hundreds of documents, the LLM will generate a wide variety of tags. Your next step is to review the full list of generated tags, consolidate synonyms, and formalize it as a controlled vocabulary.

For example, you might find the LLM has generated variations like "Sent-down Youth", "Rustication", "Xiaxiang Movement", and "Youth Resettlement" — all referring to the same phenomenon. You would standardize these to a single preferred term (e.g., "Sent-down Youth") and do a find-and-replace across your metadata spreadsheet.

A quick way to see all unique tags generated across your collection is to run the following in Python:

```python
import json
from collections import Counter

with open("metadata_output.json", encoding="utf-8") as f:
    records = json.load(f)

all_tags = [tag for record in records for tag in record.get("tags", [])]
tag_counts = Counter(all_tags).most_common(50)
for tag, count in tag_counts:
    print(f"{count:4d}  {tag}")
```

This will print a ranked list of the 50 most common tags, giving you a clear picture of the thematic structure of your collection and which terms need to be consolidated.

<div class="workflow-warning">
<strong>Human-in-the-Loop Verification:</strong> While LLMs are highly effective at extracting metadata, OCR errors in the source text can cause the model to "hallucinate" — generating plausible-sounding but incorrect metadata to fill gaps in degraded text [9]. In one documented experiment, Gemini Pro inserted invented characters to complete a truncated sentence without flagging the gap [9]. It is critical to treat all AI-generated metadata as a first draft. A human researcher must review the generated spreadsheet against the original PDFs — particularly checking dates, titles, and issuing authorities — before importing the data into your archive [8].
</div>

---

## Phase 3: Setting Up Omeka Classic

Omeka Classic is a free, open-source web publishing platform developed by the Roy Rosenzweig Center for History and New Media, designed specifically for scholars, librarians, and archivists to display digital collections [11]. It is the platform underlying both the Maoist Legacy Database and the Grassroots Chinese History Archive.

### Step 3.1: Installation

Omeka Classic requires a standard LAMP stack (Linux, Apache, MySQL, PHP 7.x). Most university web hosting services and commercial providers such as Reclaim Hosting offer one-click Omeka installation. If you are setting up your own server, follow the [official installation guide](https://omeka.org/classic/docs/Installation/Installing/){:target="_blank"} [12].

After installation, log in to the Omeka admin panel at `https://yoursite.edu/omeka/admin`. The first thing you should do is set your site title, description, and timezone under **Settings → General**.

### Step 3.2: Installing Core Plugins

Navigate to **Plugins** in the admin panel and install the following three plugins before doing anything else. All are available free from the [official Omeka plugin directory](https://omeka.org/classic/plugins/){:target="_blank"}:

| Plugin | What It Does |
|--------|--------------|
| **CSV Import** | Bulk-uploads hundreds of items and their metadata from a single spreadsheet, and can automatically attach PDF files from URLs [13] |
| **PDF Text** | Extracts the invisible OCR text layer from uploaded PDFs and saves it to the Omeka database, enabling full-text search across document contents [14] |
| **Search by Metadata** | Lets users click any metadata value (e.g., a Subject tag) to find all other items sharing that value — essential for taxonomy-based browsing |

After installing each plugin, click **Activate** to enable it. You will not need to configure them yet; that happens during the import step.

---

## Phase 4: Metadata Schema and Bulk Import

Omeka Classic uses the **Dublin Core** metadata standard by default, which provides 15 universal fields for describing digital objects [15]. The fields map directly to what the LLM extracted in Phase 2.

### Step 4.1: Structuring Your CSV

Take the JSON output generated by your LLM in Phase 2 and convert it into a master spreadsheet (in Excel or Google Sheets) where each row represents a single historical document. The column headers must follow the exact format that the CSV Import plugin expects: `Dublin Core:FieldName`.

Here is an example of how your CSV should look:

| Dublin Core:Title | Dublin Core:Date | Dublin Core:Creator | Dublin Core:Subject | Dublin Core:Description | file |
|---|---|---|---|---|---|
| 关于农村工作若干问题的决定 | 1966-05-16 | 中共中央 | Land Reform; Collectivization | Decision on several questions regarding rural work... | https://yourserver.edu/files/1966-05-16_Zhongfa_267.pdf |
| 关于知识青年上山下乡的指示 | 1968-12-22 | 中共中央 | Sent-down Youth; Rural Policy | Directive on educated youth going to the mountains... | https://yourserver.edu/files/1968-12-22_Zhongfa_198.pdf |

<div class="workflow-note">
<strong>Multiple values in a single field:</strong> To assign multiple subject tags to a single item (as in the <code>Dublin Core:Subject</code> column above), separate each value with a semicolon (<code>;</code>). The CSV Import plugin will split these into separate Subject entries in Omeka, which is exactly what you want for faceted browsing.
</div>

### Step 4.2: Running the Import

Before running the import, upload all of your searchable PDFs to a publicly accessible web server (your university's file server, an S3 bucket, or the same server running Omeka). The `file` column in your CSV must contain the direct, publicly accessible URL to each PDF.

Then, in the Omeka admin panel:

1. Navigate to **Plugins → CSV Import → Import Items**
2. Upload your CSV file and set the character encoding to **UTF-8**
3. Map each column to its corresponding Omeka field (the plugin will auto-detect `Dublin Core:` prefixed columns)
4. Set the **File** column to be treated as a file URL
5. Click **Import**

The plugin will create one Omeka item per row, populate all metadata fields, and download and attach the corresponding PDF. For a collection of 500 items, this process typically takes 10–20 minutes.

---

## Phase 5: Configuring Chinese Full-Text Search

The default search engine in Omeka Classic relies on MySQL full-text search, which is generally inadequate for parsing Chinese text because it relies on spaces to identify word boundaries — a system that works for English but fails entirely for Chinese, where words are not separated by spaces.

### Step 5.1: Apache Solr with the Smart Chinese Analyzer

The Maoist Legacy Database utilizes Apache Solr equipped with Lucene's Smart Chinese Analyzer [7]. This analyzer uses a built-in dictionary to tokenize modern Chinese text into meaningful word units, allowing the search engine to correctly identify two-character cognates and rank results by relevance.

To implement this on your server:

1. **Install Apache Solr** (version 8.x recommended) following the [official Solr documentation](https://solr.apache.org/guide/8_11/installing-solr.html){:target="_blank"}
2. **Add the Smart Chinese Analyzer** by including the `lucene-analyzers-smartcn` JAR in your Solr configuration
3. **Install the SolrSearch plugin** for Omeka from the plugin directory
4. **Configure the plugin** by pointing it to your Solr instance URL (typically `http://localhost:8983/solr/omeka`)
5. **Re-index your collection** by clicking **Reindex** in the SolrSearch plugin settings

Once configured, the plugin will index the metadata from your CSV import alongside the full text extracted from your PDFs by the PDF Text plugin, making every word in every document searchable.

### Step 5.2: Advanced Search as a Fallback

Even with Solr and the Smart Chinese Analyzer, certain searches will fail — particularly for rare political jargon not in the standard dictionary, single-character searches, or second-round simplified characters (二简字) that were never standardized [7].

The recommended solution is to ensure users have access to Omeka's built-in **Advanced Search** interface, which performs exact-match character string searches across specific Dublin Core fields. This allows researchers to search for unusual terms or specific character combinations that the tokenizer cannot handle.

To enable Advanced Search, navigate to **Settings → Search** in the Omeka admin panel and ensure the "Search by specific fields" option is activated.

<div class="workflow-note">
<strong>Search tip for users:</strong> When a keyword search returns no results, try the Advanced Search and search the <em>Description</em> or <em>Title</em> fields directly using exact character strings. This bypasses the tokenizer entirely and performs a direct string match against the stored text.
</div>

---

## Summary: The Complete Workflow

| Phase | Key Action | Output |
|-------|-----------|--------|
| **1. Preparation & OCR** | Pre-process scans → run OCRmyPDF/ABBYY/PaddleOCR | Folder of searchable PDFs |
| **2. AI Metadata** | LLM extracts title, date, authority, tags via API | Verified master spreadsheet (CSV) |
| **3. Omeka Setup** | Install LAMP stack + Omeka + 3 plugins | Live archive platform |
| **4. Bulk Import** | Upload CSV + PDFs via CSV Import plugin | Populated Omeka database |
| **5. Search** | Install Apache Solr + Smart Chinese Analyzer | Full-text Chinese search |

For a collection of 500 documents, the full workflow typically takes 2–4 weeks, with the majority of time spent on OCR correction and human verification of AI-generated metadata.

---

## References

[1] The Maoist Legacy Database. "About." Accessed April 16, 2026. <https://www.maoistlegacy.de/db/about>

[2] Grassroots Chinese History Archive. "About." Accessed April 16, 2026. <https://grassrootschinesehistory.ca/about>

[3] Tech for Humans. "Image Pre-Processing Techniques for OCR." *Medium*, April 2, 2025.

[4] ABBYY. "Supported OCR and document comparison languages." Accessed April 16, 2026. <https://www.abbyy.com>

[5] Koncile. "PaddleOCR: analysis, benefits and open source alternatives." March 19, 2026.

[6] OCRmyPDF. "Documentation." Accessed April 16, 2026. <https://ocrmypdf.readthedocs.io/>

[7] The Maoist Legacy Database. "User Guide." Accessed April 16, 2026. <https://www.maoistlegacy.de/db/how-to>

[8] Huang, Abigail Yongping, et al. "Web Archives Metadata Generation with gpt-4o: Challenges and Insights." *arXiv preprint* arXiv:2411.05409 (2024).

[9] Chow, Eric H. C. "An Experiment with Gemini Pro LLM for Chinese OCR and Metadata Extraction." *The Digital Orientalist*, April 5, 2024.

[10] LlamaIndex. "AI Document Classification: A Practical Guide." March 31, 2026.

[11] Omeka. "Omeka Classic." Accessed April 16, 2026. <https://omeka.org/classic/>

[12] Omeka Classic User Manual. "Installation." Accessed April 16, 2026. <https://omeka.org/classic/docs/Installation/Installing/>

[13] Omeka Classic User Manual. "CSV Import." Accessed April 16, 2026. <https://omeka.org/classic/docs/Plugins/CSV_Import/>

[14] Omeka Classic User Manual. "PDF Text." Accessed April 16, 2026. <https://omeka.org/classic/docs/Plugins/PdfText/>

[15] Omeka Classic User Manual. "Working with Dublin Core." Accessed April 16, 2026. <https://omeka.org/classic/docs/Content/Working_with_Dublin_Core/>
