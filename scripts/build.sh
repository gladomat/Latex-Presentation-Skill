#!/usr/bin/env bash
# build.sh <deck.tex> — compile a Swiss-theme Beamer deck, report layout problems, render page previews.
# Exit 0 = PDF built and no overflow; 1 = compile error; 2 = PDF built but frames overflow.
set -u
tex="${1:?usage: build.sh path/to/deck.tex}"
dir="$(cd "$(dirname "$tex")" && pwd)"; base="$(basename "$tex" .tex)"
cd "$dir" || exit 1
# pygmentize (needed by minted) is often installed with pip/uv into ~/.local/bin, which agent shells may not have on PATH.
export PATH="$HOME/.local/bin:$PATH"

latexmk -xelatex -shell-escape -interaction=nonstopmode -halt-on-error "$base.tex" > "$base.build.log" 2>&1
if [ ! -f "$base.pdf" ] || grep -q '^! ' "$base.log"; then
  echo "COMPILE FAILED. First error:"
  grep -n -A6 '^! ' "$base.log" | head -20
  exit 1
fi

pages=$(pdfinfo "$base.pdf" 2>/dev/null | awk '/^Pages:/{print $2}')
echo "PDF: $dir/$base.pdf ($pages pages)"

# Overfull \vbox = content cut off at the bottom of a frame. Line number = the frame's \end{frame} (or macro call).
# Overfull \hbox > 3pt = text/figure sticking out past the right margin.
over=$(grep -E '^Overfull \\vbox \(([2-9]|[1-9][0-9]+)\.' "$base.log"; grep -E '^Overfull \\hbox \(([3-9]|[1-9][0-9]+)\.' "$base.log")
missing=$(grep -E "LaTeX Warning: (File|Reference|Citation).*(not found|undefined)|Missing character" "$base.log" | sort -u)

mkdir -p previews && rm -f previews/page-*.png
pdftoppm -png -r 60 "$base.pdf" previews/page >/dev/null 2>&1 && echo "Previews: $dir/previews/page-*.png"

status=0
if [ -n "$over" ]; then
  echo "OVERFLOW (fix every one — shorten, split the frame, or shrink the figure):"
  echo "$over" | sed -E 's/^/  /'
  status=2
fi
if [ -n "$missing" ]; then
  echo "WARNINGS:"; echo "$missing" | sed -E 's/^/  /'
fi
[ $status -eq 0 ] && echo "LAYOUT OK: no overflow detected"
exit $status
