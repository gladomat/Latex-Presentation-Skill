# latex-presentation

A [Claude Code](https://claude.com/claude-code) skill that turns reference files and a prompt into a compiled LaTeX Beamer presentation (16:9 PDF) in a Swiss minimal theme.

```
/latex-presentation notes.md results.csv — 8-slide project update for my team lead: what worked, what failed, next steps
```

Claude reads the references, plans one message per slide, writes the `.tex`, compiles it with XeLaTeX, fixes every overflowing slide, and checks rendered previews of each page before it reports back.

## What it does

1. Splits the arguments into reference files/directories and the prompt (audience, length, language, variant).
2. Reads the references and collects the core message, exact numbers, figures and code snippets. Missing numbers become visible `TODO` markers instead of invented values.
3. Plans the story: sections, one takeaway per frame, special slides (KPI row, statement, full-bleed image, closing).
4. Writes `<out>/<slug>.tex` next to a copy of the theme, within measured space limits per slide type.
5. Builds with `scripts/build.sh`, which reports compile errors and overflowing frames by source line and renders PNG previews; loops until the layout is clean.
6. Reports the PDF path, outline, assumptions and open TODOs.

Output goes to the path named in the prompt, or `./<slug>/` in the current directory.

## Install

```bash
git clone <this-repo> ~/.claude/skills/latex-presentation
```

Claude Code picks it up on the next session. Run it with `/latex-presentation …`, or just ask for a LaTeX/Beamer deck.

## Requirements

- TeX Live or MacTeX with XeLaTeX and `latexmk`
- Pygments (`pygmentize` on `PATH`) for `minted` code slides
- Poppler (`pdftoppm`, `pdfinfo`) for previews — `brew install poppler` / `apt install poppler-utils`

Fonts: Helvetica Neue → Helvetica → TeX Gyre Heros; mono: SF Mono → Menlo → DejaVu Sans Mono.

## Layout

```
SKILL.md                    instructions Claude follows
assets/beamerthemeswiss.sty Swiss Beamer theme
assets/demo.tex             every slide type, sized to fit
assets/theme-README.md      theme options and helper commands
scripts/build.sh            compile + overflow check + PNG previews
```

## Theme options

```latex
\usetheme[accent=E63312]{swiss}   % single accent, any hex (default)
\usetheme[colorful]{swiss}        % section pages cycle blue → pink → yellow → purple → orange
```

Ask for a "colourful" deck in the prompt to get the second variant. See `assets/theme-README.md` for `\kpi`, `\fullbleed`, `\statement`, `\closingframe`, `\thead` and the `swiss`/`swissbar` pgfplots styles.

## Build a deck by hand

```bash
bash scripts/build.sh path/to/deck.tex   # exit 0 clean, 1 compile error, 2 overflow
```
