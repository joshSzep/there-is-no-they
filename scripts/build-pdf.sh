#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
MANUSCRIPT_SCRIPT="$SCRIPT_DIR/build-manuscript.sh"
MANUSCRIPT_FILE="$REPO_ROOT/MANUSCRIPT.md"
COVER_FILE="$REPO_ROOT/cover.png"
OUTPUT_FILE="$REPO_ROOT/There Is No They.pdf"

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: required command '$1' is not installed or not on PATH." >&2
        exit 1
    fi
}

require_file() {
    if [ ! -f "$1" ]; then
        echo "Error: required file '$1' was not found." >&2
        exit 1
    fi
}

require_command pandoc
require_command pdflatex
require_command awk
require_command mktemp

require_file "$MANUSCRIPT_SCRIPT"
require_file "$COVER_FILE"

"$MANUSCRIPT_SCRIPT"
require_file "$MANUSCRIPT_FILE"

TMP_DIR="$(mktemp -d)"
HEADER_FILE="$TMP_DIR/pdf-header.tex"
SOURCE_FILE="$TMP_DIR/manuscript-for-pdf.md"

cleanup() {
    rm -rf "$TMP_DIR"
}

trap cleanup EXIT

cat > "$HEADER_FILE" <<'EOF'
\usepackage[paperwidth=6in,paperheight=9in,inner=0.8in,outer=0.8in,top=0.9in,bottom=0.95in]{geometry}
\usepackage[T1]{fontenc}
\usepackage[utf8]{inputenc}
\usepackage{mathpazo}
\usepackage{graphicx}
\usepackage{eso-pic}
\usepackage{xcolor}
\usepackage{titlesec}
\usepackage{setspace}
\usepackage{parskip}
\usepackage[hidelinks]{hyperref}

\definecolor{headinggray}{HTML}{5B6672}
\definecolor{textgray}{HTML}{25303A}

\color{textgray}
\setstretch{1.07}
\setlength{\parindent}{0pt}
\widowpenalty=10000
\clubpenalty=10000
\raggedbottom
\pagestyle{plain}

\titleformat{\section}
  {\clearpage\thispagestyle{plain}\centering\normalfont\Large\scshape\color{headinggray}}
  {}
  {0pt}
  {}

\titlespacing*{\section}{0pt}{0pt}{1.5em}

\titleformat{\subsection}
  {\normalfont\LARGE\bfseries\color{textgray}}
  {}
  {0pt}
  {}

\titlespacing*{\subsection}{0pt}{1.6em}{0.9em}

\titleformat{\subsubsection}
  {\normalfont\large\bfseries\color{textgray}}
  {}
  {0pt}
  {}

\titlespacing*{\subsubsection}{0pt}{1.2em}{0.6em}
EOF

cat > "$SOURCE_FILE" <<'EOF'
```{=latex}
\newgeometry{margin=0in}
\AddToShipoutPictureBG*{\AtPageLowerLeft{\includegraphics[width=\paperwidth,height=\paperheight]{
EOF

printf '%s' "$COVER_FILE" >> "$SOURCE_FILE"

cat >> "$SOURCE_FILE" <<'EOF'
}}}
	\thispagestyle{empty}
\null
\clearpage
\ClearShipoutPictureBG
\restoregeometry
\setcounter{page}{1}
```

EOF

awk '
    BEGIN { in_body = 0 }
    /^## / { in_body = 1 }
    !in_body { next }
    /^### / { sub(/^### /, "## "); print; next }
    /^## / { sub(/^## /, "# "); print; next }
    { print }
' "$MANUSCRIPT_FILE" >> "$SOURCE_FILE"

pandoc \
    --from markdown+raw_tex \
    --standalone \
    --pdf-engine=pdflatex \
    --include-in-header "$HEADER_FILE" \
    --variable documentclass=article \
    --variable fontsize=11pt \
    --output "$OUTPUT_FILE" \
    "$SOURCE_FILE"

echo "PDF built: $OUTPUT_FILE"
echo "Word count: $(wc -w < "$MANUSCRIPT_FILE" | tr -d ' ')"