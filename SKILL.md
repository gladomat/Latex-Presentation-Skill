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

**Results decks: every number must explain itself.** The audience did not read the source reports. For decks built from experiment results, plan these from the start instead of waiting for "what does this mean?":

- **Method before result.** Each method, fix or model variant that a result slide reports on gets a short "How X works" frame (or at least a one-line definition on the result frame) placed *before* it: what is computed, from which data, and how it enters the score or the model. A small worked example or illustrative chart helps; label invented values "Illustrative values".
- **No internal codes.** Never put run labels, arm codes or project jargon on a slide (`E3`, `pop1`, `Phase F`, `session-4 margin`, commit hashes). Use descriptive names ("date feature", "popularity blend"); keep codes for the talking notes. Spell out every abbreviation once (e.g. "out-of-vocabulary (OOV)").
- **Say what is compared with what.** Every delta names both sides, the period and the population ("fresh model vs 9-week-old model, same users, October"). Every percentage names what it is a share of ("fall/wint share of the top-100", not "the mix"). Avoid vague pronouns ("moves both" → "lifts auc and the fall/wint share").
- **Explain thresholds and units.** A decision margin or threshold gets its origin in plain words ("twice the seed-to-seed spread"), not its label. A rate gets its unit and meaning ("each week without a retrain costs 0.004").
- **Keep similar terms apart.** If the source has two things with similar names (e.g. a daily *input refresh* and a weekly *retrain*), name them distinctly on every slide.
- **Complete tables.** Include every arm, variant and aggregate row the source reports for that comparison (for example "all users"), not only the interesting ones. Mark significant differences (`*` = interval excludes 0) and footnote the group and parameter definitions.
- **Deployment questions.** If a recommendation changes how something runs in production, expect "how would this work in our system?" and add a backup slide for it.

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

More measured limits:
- **Frame titles: at most about 33 characters.** Longer titles wrap to two lines and push content off the frame. Subtitles: one line, about 70 characters.
- **Footnotes under a table or chart:** `{\scriptsize\color{swissMuted} …}`, at most two or three one-line notes; a wrapped note costs a whole line.
- **Three `\kpi`s in a row:** numbers longer than about 6 characters (`−0.0271`, `+0.0533`) overflow; wrap them as `\kpi{\fontsize{26}{30}\selectfont −0.0271}{…}` and keep labels to about 30 characters.
- **Wide tables with intervals:** put each 95% interval on its own row under the value in `{\tiny\color{swissMuted}[lo, hi]}`, with `\renewcommand{\arraystretch}{0.9}`, instead of shrinking the whole table.

Charts:
- Error bars must stay visible: `mark size=0.9pt` on the points, `error bar style={line width=0.9pt,color=swissAccent}`, and asymmetric intervals typed exactly (`(x,y) += (0,hi−y) -= (0,y−lo)`), never a symmetric approximation.
- Draw thresholds as a dashed line with a label, inside the y range (raise `ymax` so the label fits).
- Put legends above the plot (`at={(0.5,1.03)},anchor=south,legend columns=3,draw=none`) when lines fill the plot area.
- In bar charts, give each series an explicit solid fill (`fill=swissMuted`, `fill=swissAccent!40`, `fill=swissAccent`) and `area legend`; the default styles are too faint to read.
- Use `scaled y ticks=false` with fixed number format so axes do not show `×10⁻²`.

### 5. Build and fix until clean

Run `bash <skill-dir>/scripts/build.sh <out>/<slug>.tex`.

- **Exit 1**: read the quoted error, fix the source, rebuild. Missing fonts are handled by the theme's fallbacks; a minted error usually means Pygments is missing or `[fragile]` was forgotten.
- **Exit 2**: every listed `Overfull \vbox … at line N` is a frame whose bottom is cut off (N is that frame's `\end{frame}`). Split it, cut words, or shrink the figure — then rebuild. `Overfull \hbox` means something sticks out at the right; shorten or narrow it.
- Repeat until the script prints `LAYOUT OK`.

Then **look at the previews**: open `previews/page-*.png` with the Read tool (all of them for decks ≤ 20 pages, otherwise every content-heavy page). The log can't see everything — check for text colliding with the page number or progress bar, images too small to read, empty-looking frames, awkward line breaks in titles, and `TODO` markers. Fix and rebuild if needed.

The bundled previews are low resolution. For any frame with a chart, a dense table or small notes, render it larger before judging it: `pdftoppm -f N -l N -r 140 -png <deck>.pdf <scratch>/p` and read that file. Small markers hiding error bars, legends covering lines and notes touching the page number only show at this size.

**Consistency pass.** Before reporting, and again after every change to a recommendation, check that results, summary frames and the closing `\statement` say the same thing. A recommendation changed on one result slide must be propagated to the summary and the closing line in the same turn. Mark which recommendations are your own judgment rather than a rule from the source, so the user can confirm them.

**Edits on request.** After each user-requested change, rebuild, render the changed frame at `-r 140`, read it, and only then report. If the `.tex` changed on disk since your last edit (the user edits it too), re-read it and keep their wording unless it breaks the layout; say what you adjusted.

### 6. Report

Reply with: the PDF path, the .tex path, page count, a one-line outline of the sections, every assumption made (placeholders for author/date, inferred audience, etc.), and any `TODO`s left for missing data. Keep build artefacts (`.aux`, `.log`, `_minted*`) — `latexmk -c` in the output dir removes them if the user wants.

For a results deck the user will present, offer **talking notes** as `<out>/talking-notes.md`: one `## N. Frame title` section per frame with bullets that add the detail behind the slide (how each number was measured, intervals, caveats, source file), plus a glossary at the top and the open items that were cut from the slides. They are for looking things up during questions, not for reading aloud. Keep slide numbers and wording in sync whenever the deck changes.
