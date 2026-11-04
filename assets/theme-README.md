# Swiss Beamer theme

Swiss modern minimal theme for Beamer, 16:9, light paper background, single accent.

## Files
- `beamerthemeswiss.sty` — the theme
- `demo.tex` — single-accent variant, every slide type; copy it as your starting point
- `demo-colorful.tex` — multi-colour variant (blue / pink / yellow / purple / orange)

## Compile
Requires XeLaTeX or LuaLaTeX (fontspec) and `-shell-escape` for minted (Pygments installed).

    latexmk -xelatex -shell-escape demo.tex

Fonts: uses Helvetica Neue if installed (macOS), falls back to Helvetica, then TeX Gyre Heros (ships with TeX Live). Mono: SF Mono → Menlo → DejaVu Sans Mono.

## Reuse
Put `beamerthemeswiss.sty` next to your `.tex`, or install it once into `~/texmf/tex/latex/swiss/`. On Overleaf: upload the `.sty` to the project root.

## Options
    \usetheme[accent=1F4FD8]{swiss}   % single accent, any hex, default E63312
    \usetheme[colorful]{swiss}        % multi-colour: section pages get full-colour backgrounds
                                      % cycling blue → pink → yellow → purple → orange; accents follow the section

## Provided commands
- `\kpi[color]{99.9\%}{label}` — big number block, optional colour (place 3 side by side with `\hfill`)
- `\fullbleed[caption]{image}` — full-page image slide
- `\statement{One sentence}` — single-thought slide
- `\closingframe{Thank you}{line \\ line}` — contact slide, shows `\titlegraphic` if set
- `\thead{Column}` — muted table header cell (use with booktabs)
- pgfplots styles `swiss` (lines) and `swissbar` (bars): `\begin{axis}[swissbar,...]`
- Colors: `swissAccent`, `swissInk`, `swissMuted`, `swissRule`, `swissPaper`, `swissBlue`, `swissPink`, `swissYellow`, `swissPurple`, `swissOrange`
- `\swissblocks{0.5cm}` — the five colour blocks mark

Section slides are inserted automatically at every `\section{}`; frames with a subtitle use `\begin{frame}{Title}{Subtitle}`.
