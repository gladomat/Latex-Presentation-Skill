---
name: latex-presentation
description: Build a LaTeX Beamer presentation (16:9 PDF) in the Swiss minimal theme from reference files plus a prompt, compile it with XeLaTeX, and visually check every slide. Use when the user runs /latex-presentation, or asks for a LaTeX/Beamer deck, slides as .tex, a "Swiss" presentation, or turning notes, a report, results, code or a paper into a LaTeX presentation — even if they only say "make slides from these files" in a LaTeX context.
argument-hint: "[reference files/dirs...] <what the deck should say, audience, length>"
---

# LaTeX presentation (Swiss theme)

Turn the user's reference material and prompt into a compiled Beamer deck that uses the bundled Swiss theme, with no clipped or overflowing slides.

Request: $ARGUMENTS

## Bundled files

- `assets/beamerthemeswiss.sty` — the theme. Copy it next to the deck. (Copied from `~/src/github.com/presentation-template-swiss/`; re-copy from there if the template changes.)
- `assets/demo.tex` — one example of every slide type, sized to fit. Read it before writing; copy its patterns.
- `assets/theme-README.md` — option and command reference (`\kpi`, `\fullbleed`, `\statement`, `\closingframe`, `\thead`, `swiss`/`swissbar` pgfplots styles, colours).
- `scripts/build.sh <deck.tex>` — compiles (latexmk, XeLaTeX, `-shell-escape`), lists overflowing frames by source line, renders `previews/page-NN.png`. Exit 0 = clean, 1 = compile error, 2 = overflow.

## Workflow

### 1. Parse the request

Split `$ARGUMENTS` into **references** (anything that resolves to an existing file, directory or glob) and the **prompt** (the rest). If no prompt is given, infer the purpose from the references and state the assumption in the final reply. Only ask a question if the request is unusable without the answer (e.g. no references and no topic).

From the prompt pick up, with defaults:
- **Audience and goal** — shapes depth and wording. Default: technical peers.
- **Length** — a slide count in the prompt ("6 slides", "6 Folien") means **content frames only**; title, agenda, automatic section pages and the closing frame come on top and are not counted. Default about 10–15 content frames; a "5 minute" talk ≈ 5–7 frames.
- **Language** — the language of the prompt, unless told otherwise. Set `\usepackage[ngerman]{babel}`-style hyphenation only if needed; the theme itself is language-neutral.
- **Variant** — single accent (`\usetheme[accent=E63312]{swiss}`, any hex) by default; `\usetheme[colorful]{swiss}` if the user asks for colourful/multi-colour.
- **Title-page fields** — author, institute, date. Use what the references or prompt give; otherwise use today's date and leave author/institute as obvious placeholders and say so.
- **Output location** — a path named in the prompt, else `./<short-kebab-slug>/` in the current working directory. Never write into the template repo.

### 2. Read the references properly

The deck is only as good as its grounding. Read every reference (PDF via the pdf tooling or `pdftotext`, notebooks, code, CSV/JSON, markdown, images). For a directory, list it first and read what is relevant. While reading, collect:
- the core message and 3–5 supporting points,
- concrete numbers (for `\kpi` slides, tables, charts) — **copy them exactly, never invent or round beyond the source**; if a number is needed but missing, leave a visible `\alert{TODO: …}` instead of guessing,
- figures worth reusing (PNG/JPG/PDF) — copy them into `<out>/figures/`,
- short code snippets worth showing.

### 3. Plan the story before writing LaTeX

Write a short outline (in your head or as a comment block at the top of the .tex): sections → frames, one message per frame, each frame title phrased as the takeaway ("Latency dropped 4× after caching", not "Results"). Typical arc: title → agenda (only if ≥3 sections) → context/problem → approach → results/evidence → implications/next steps → closing. Use the theme's special slides where they earn their place: `\kpi` row for headline numbers, `\statement` for the one sentence the audience must remember, `\fullbleed` for a strong photo/figure, `\closingframe` at the end.

### 4. Write the deck

First read `assets/theme-README.md` and `assets/demo.tex` in full — the README lists every theme option and helper command, the demo shows how each is used at a size that fits. Then copy `assets/beamerthemeswiss.sty` into the output directory and create `<out>/<slug>.tex`, starting from the preamble in `assets/demo.tex` (drop `\usepackage{mwe}` unless you use its placeholder images). Conventions:

- `\section{}` automatically inserts a section slide — don't add one manually.
- Frame with subtitle: `\begin{frame}{Title}{Subtitle}`. Any frame containing `minted` needs `[fragile]`.
- Code that itself contains a line starting with `\end{frame}` (e.g. a LaTeX/Beamer example) ends a `[fragile]` frame early and breaks the build. Put such code in `<out>/code/<name>.tex` and load it with `\inputminted{latex}{code/<name>.tex}`.
- Keep inline code short: `\verb` and `\texttt` never break lines, so a long command overflows a column. Inside `columns` or tables, use `{\footnotesize\verb|…|}` or move the command into a table row / code block.
- Escape LaTeX specials in copied text: `% & $ # _ { } ~ ^ \`. Use `--`/`–` for ranges, `\,` thin spaces in numbers if needed.
- Tables: `booktabs` with `\thead{}` header cells, as in the demo. Charts: `\begin{axis}[swiss,...]` or `[swissbar,...]` with data typed in from the references.
- Images: `\includegraphics[height=…,width=\textwidth,keepaspectratio]{figures/x}`.
- `\alert{}` for the single word or phrase that matters on a frame — sparingly.

**Space budget.** The frame title block takes about a third of the 16:9 page, so content space is small. These limits come from measuring the theme; staying under them avoids most overflow fixes:

| Content | with subtitle | without subtitle |
|---|---|---|
| Bullets (items + subitems, one line each) | 5 | 6 |
| Table body rows (+ caption) | 3 | 4 |
| Code lines (`minted`, footnotesize) | 7 | 9 |
| Image height | 3.5 cm | 4.2 cm |
| Chart (`swiss`/`swissbar`) | `height=0.5\textheight` | `height=0.55\textheight` |
| Two-column `block`s | 2–3 lines of text each, nothing below | same |

Bullets longer than one line count double. More content than this means two frames, not smaller fonts — splitting keeps the theme's typography intact.

### 5. Build and fix until clean

Run `bash <skill-dir>/scripts/build.sh <out>/<slug>.tex`.

- **Exit 1**: read the quoted error, fix the source, rebuild. Missing fonts are handled by the theme's fallbacks; a minted error usually means Pygments is missing or `[fragile]` was forgotten.
- **Exit 2**: every listed `Overfull \vbox … at line N` is a frame whose bottom is cut off (N is that frame's `\end{frame}`). Split it, cut words, or shrink the figure — then rebuild. `Overfull \hbox` means something sticks out at the right; shorten or narrow it.
- Repeat until the script prints `LAYOUT OK`.

Then **look at the previews**: open `previews/page-*.png` with the Read tool (all of them for decks ≤ 20 pages, otherwise every content-heavy page). The log can't see everything — check for text colliding with the page number or progress bar, images too small to read, empty-looking frames, awkward line breaks in titles, and `TODO` markers. Fix and rebuild if needed.

### 6. Report

Reply with: the PDF path, the .tex path, page count, a one-line outline of the sections, every assumption made (placeholders for author/date, inferred audience, etc.), and any `TODO`s left for missing data. Keep build artefacts (`.aux`, `.log`, `_minted*`) — `latexmk -c` in the output dir removes them if the user wants.
