#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
MANUSCRIPT_FILE="$REPO_ROOT/MANUSCRIPT.md"
OUTPUT_DIR="$REPO_ROOT/website"
INDEX_FILE="$OUTPUT_DIR/index.html"
OUTPUT_COVER="$OUTPUT_DIR/cover.png"
OUTPUT_PDF="$OUTPUT_DIR/There Is No They.pdf"
SOURCE_COVER="$REPO_ROOT/cover.png"
SOURCE_PDF="$REPO_ROOT/There Is No They.pdf"

require_file() {
    if [ ! -f "$1" ]; then
        echo "Error: required file '$1' was not found." >&2
        exit 1
    fi
}

extract_excerpt() {
    awk '
        BEGIN {
            in_chapter = 0
            done = 0
            count = 0
            limit = 10
            paragraph = ""
        }

        function flush_paragraph() {
            if (paragraph == "") {
                return
            }

            if (count < limit) {
                paragraphs[++count] = paragraph
            }

            paragraph = ""

            if (count >= limit) {
                done = 1
            }
        }

        /^### Chapter 01 - The Fog$/ {
            in_chapter = 1
            next
        }

        /^### Chapter 02 - Daniel$/ {
            if (in_chapter) {
                done = 1
            }
            next
        }

        !in_chapter || done {
            next
        }

        /^---$/ {
            next
        }

        $0 == "" {
            flush_paragraph()
            next
        }

        {
            if (paragraph == "") {
                paragraph = $0
            } else {
                paragraph = paragraph " " $0
            }
        }

        END {
            if (!in_chapter) {
                exit 1
            }

            flush_paragraph()

            for (i = 1; i <= count; i++) {
                print paragraphs[i]
                if (i < count) {
                    print ""
                }
            }
        }
    ' "$MANUSCRIPT_FILE"
}

excerpt_to_html() {
    awk '
        function escape_html(text) {
            gsub(/&/, "\\&amp;", text)
            gsub(/</, "\\&lt;", text)
            gsub(/>/, "\\&gt;", text)
            return text
        }

        function emit_paragraph() {
            if (paragraph == "") {
                return
            }

            print "                <p>" paragraph "</p>"
            paragraph = ""
        }

        {
            if ($0 == "") {
                emit_paragraph()
                next
            }

            line = escape_html($0)

            if (paragraph == "") {
                paragraph = line
            } else {
                paragraph = paragraph " " line
            }
        }

        END {
            emit_paragraph()
        }
    '
}

require_file "$MANUSCRIPT_FILE"
require_file "$SOURCE_COVER"
require_file "$SOURCE_PDF"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

EXCERPT_TXT="$TMP_DIR/chapter-01-excerpt.txt"
EXCERPT_HTML="$TMP_DIR/chapter-01-excerpt.html"

extract_excerpt > "$EXCERPT_TXT"

if [ ! -s "$EXCERPT_TXT" ]; then
    echo "Error: failed to extract Chapter 01 preview from '$MANUSCRIPT_FILE'." >&2
    exit 1
fi

excerpt_to_html < "$EXCERPT_TXT" > "$EXCERPT_HTML"

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

cp "$SOURCE_COVER" "$OUTPUT_COVER"
cp "$SOURCE_PDF" "$OUTPUT_PDF"

cat > "$INDEX_FILE" <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>There Is No They | Joshua Szepietowski</title>
    <meta name="description" content="A literary science fiction novel by Joshua Szepietowski about failed communication, loneliness, and the distance language cannot cross.">
    <meta property="og:title" content="There Is No They">
    <meta property="og:description" content="A quiet, unsettling literary science fiction novel about alien signals, failed translation, and the cost of seeing.">
    <meta property="og:type" content="website">
    <meta property="og:image" content="cover.png">
    <link rel="preload" href="cover.png" as="image">
    <style>
        :root {
            --bg: #091118;
            --bg-soft: #13202a;
            --panel: rgba(14, 23, 31, 0.66);
            --panel-strong: rgba(13, 21, 29, 0.82);
            --text: #e7e4de;
            --muted: #aeb7bb;
            --muted-deep: #7f8b92;
            --line: rgba(233, 236, 237, 0.13);
            --warm: #d5b58d;
            --fog: rgba(242, 242, 242, 0.08);
            --shadow: 0 30px 70px rgba(0, 0, 0, 0.28);
            --radius: 28px;
            --content: 1200px;
            --copy: 660px;
            --serif: "Iowan Old Style", "Palatino Linotype", "Book Antiqua", "URW Palladio L", "Baskerville", Georgia, serif;
            --sans: "Avenir Next", "Segoe UI", "Optima", Candara, "Noto Sans", sans-serif;
        }

        * {
            box-sizing: border-box;
        }

        html {
            scroll-behavior: smooth;
            background: var(--bg);
        }

        body {
            margin: 0;
            min-height: 100vh;
            color: var(--text);
            font-family: var(--sans);
            background:
                radial-gradient(circle at 20% 18%, rgba(213, 181, 141, 0.12), transparent 0 24%),
                radial-gradient(circle at 82% 8%, rgba(135, 160, 176, 0.16), transparent 0 26%),
                linear-gradient(180deg, #20303b 0%, #111b22 32%, #091118 100%);
            overflow-x: hidden;
        }

        body::before,
        body::after {
            content: "";
            position: fixed;
            inset: 0;
            pointer-events: none;
            z-index: 0;
        }

        body::before {
            opacity: 0.16;
            background-image:
                radial-gradient(circle at 20% 30%, rgba(255, 255, 255, 0.18) 0 0.08rem, transparent 0.08rem),
                radial-gradient(circle at 80% 20%, rgba(255, 255, 255, 0.12) 0 0.07rem, transparent 0.07rem),
                radial-gradient(circle at 50% 70%, rgba(255, 255, 255, 0.14) 0 0.06rem, transparent 0.06rem);
            background-size: 210px 210px, 170px 170px, 240px 240px;
            mix-blend-mode: soft-light;
            animation: grainShift 20s steps(6) infinite;
        }

        body::after {
            background:
                radial-gradient(circle at center, transparent 42%, rgba(4, 7, 10, 0.32) 76%, rgba(3, 4, 6, 0.62) 100%);
        }

        img {
            max-width: 100%;
            display: block;
        }

        a {
            color: inherit;
            text-decoration: none;
        }

        .site-shell {
            position: relative;
            z-index: 1;
        }

        .site-header {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 10;
            padding: 1.2rem clamp(1.2rem, 2vw, 2rem);
            transition: opacity 240ms ease, background-color 240ms ease, border-color 240ms ease;
            backdrop-filter: blur(14px);
            -webkit-backdrop-filter: blur(14px);
            background: rgba(7, 12, 17, 0.18);
            border-bottom: 1px solid rgba(255, 255, 255, 0.04);
        }

        .site-header.is-scrolled {
            background: rgba(7, 12, 17, 0.42);
            border-bottom-color: rgba(255, 255, 255, 0.08);
        }

        .site-header__inner {
            width: min(100%, var(--content));
            margin: 0 auto;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
        }

        .site-header__brand,
        .site-header__links a,
        .eyebrow {
            font-size: 0.72rem;
            letter-spacing: 0.26em;
            text-transform: uppercase;
            color: var(--muted);
        }

        .site-header__brand {
            white-space: nowrap;
        }

        .site-header__links {
            display: flex;
            align-items: center;
            gap: 1.3rem;
            flex-wrap: wrap;
            justify-content: flex-end;
        }

        .site-header__links a {
            position: relative;
            transition: color 180ms ease, opacity 180ms ease;
        }

        .site-header__links a:hover,
        .site-header__links a:focus-visible {
            color: var(--text);
            opacity: 1;
        }

        .hero {
            position: relative;
            min-height: 100svh;
            display: grid;
            place-items: center;
            padding: 7rem 1.5rem 4rem;
            isolation: isolate;
        }

        .hero__image,
        .hero__veil,
        .hero__mist {
            position: absolute;
            inset: 0;
        }

        .hero__image {
            background:
                linear-gradient(180deg, rgba(6, 11, 16, 0.12), rgba(6, 11, 16, 0.6)),
                url("cover.png") center top / cover no-repeat;
            filter: saturate(0.65) brightness(0.6);
            transform: scale(1.04);
        }

        .hero__veil {
            background:
                linear-gradient(180deg, rgba(8, 12, 16, 0.28) 0%, rgba(8, 12, 16, 0.44) 34%, rgba(8, 12, 16, 0.82) 100%),
                radial-gradient(circle at 50% 38%, rgba(241, 238, 232, 0.14) 0%, transparent 28%),
                radial-gradient(circle at 50% 86%, rgba(213, 181, 141, 0.12), transparent 36%);
        }

        .hero__mist {
            background:
                radial-gradient(circle at 20% 44%, rgba(242, 242, 242, 0.16), transparent 28%),
                radial-gradient(circle at 74% 24%, rgba(242, 242, 242, 0.11), transparent 24%),
                radial-gradient(circle at 52% 70%, rgba(255, 255, 255, 0.12), transparent 33%);
            filter: blur(36px);
            opacity: 0.65;
            animation: mistDrift 24s ease-in-out infinite alternate;
        }

        .hero__mist--two {
            opacity: 0.34;
            transform: scale(1.12);
            animation-duration: 34s;
            animation-delay: -10s;
        }

        .hero__content {
            position: relative;
            text-align: center;
            max-width: 960px;
        }

        .hero__title {
            margin: 0;
            font-family: var(--serif);
            font-size: clamp(2.6rem, 8vw, 7rem);
            font-weight: 400;
            letter-spacing: 0.38em;
            line-height: 0.94;
            text-indent: 0.38em;
            text-transform: uppercase;
            color: #f0ece5;
            text-shadow: 0 12px 40px rgba(0, 0, 0, 0.35);
            opacity: 0;
            transform: translateY(18px);
            animation: titleRise 1800ms ease forwards 200ms, titleBreath 8s ease-in-out infinite 2.2s;
        }

        .hero__meta {
            margin-top: 2.2rem;
            display: grid;
            gap: 0.55rem;
            justify-items: center;
            color: rgba(231, 228, 222, 0.78);
        }

        .hero__meta p {
            margin: 0;
        }

        .hero__author {
            font-size: 0.8rem;
            letter-spacing: 0.24em;
            text-transform: uppercase;
        }

        .hero__line {
            max-width: 34rem;
            font-family: var(--serif);
            font-size: clamp(1rem, 2vw, 1.2rem);
            line-height: 1.8;
        }

        .hero__anchor {
            position: absolute;
            bottom: 2rem;
            left: 50%;
            transform: translateX(-50%);
            font-size: 0.72rem;
            letter-spacing: 0.24em;
            text-transform: uppercase;
            color: rgba(231, 228, 222, 0.68);
        }

        .hero__anchor::after {
            content: "";
            display: block;
            width: 1px;
            height: 58px;
            margin: 0.9rem auto 0;
            background: linear-gradient(180deg, rgba(231, 228, 222, 0.6), transparent);
        }

        main {
            position: relative;
        }

        .section {
            width: min(100%, var(--content));
            margin: 0 auto;
            padding: clamp(4.5rem, 8vw, 8rem) clamp(1.2rem, 2.4vw, 2rem);
        }

        .section-grid {
            display: grid;
            grid-template-columns: minmax(0, 1fr) minmax(240px, 340px);
            gap: clamp(2rem, 5vw, 5rem);
            align-items: start;
        }

        .section-copy {
            max-width: var(--copy);
        }

        .section-copy h2,
        .download__copy h2,
        .preview__copy h2,
        .closing h2 {
            margin: 0 0 1.25rem;
            font-family: var(--serif);
            font-size: clamp(2rem, 4vw, 3.4rem);
            font-weight: 400;
            letter-spacing: 0.04em;
            line-height: 1.08;
        }

        .section-copy p,
        .download__copy p,
        .preview__intro,
        .excerpt p,
        .closing__note,
        .footer {
            margin: 0;
            font-size: 1.05rem;
            line-height: 1.95;
            color: var(--muted);
        }

        .section-copy p + p,
        .download__copy p + p,
        .preview__intro + .preview__frame,
        .excerpt p + p {
            margin-top: 1.15rem;
        }

        .premise__aside {
            padding-top: 4.25rem;
        }

        .premise__card,
        .preview__frame,
        .download__panel {
            background: linear-gradient(180deg, rgba(255, 255, 255, 0.045), rgba(255, 255, 255, 0.02));
            border: 1px solid var(--line);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
        }

        .premise__card {
            padding: 1.5rem;
        }

        .premise__card p {
            font-family: var(--serif);
            font-size: 1.08rem;
            line-height: 1.9;
            color: rgba(231, 228, 222, 0.82);
        }

        .atmosphere {
            min-height: 70svh;
            display: grid;
            place-items: center;
            text-align: center;
        }

        .atmosphere__wrap {
            position: relative;
            width: min(100%, 860px);
            min-height: 240px;
            padding: 2rem 1.2rem;
        }

        .atmosphere__line {
            position: absolute;
            inset: 50% 0 auto;
            transform: translateY(-50%);
            opacity: 0;
            transition: opacity 900ms ease, transform 900ms ease;
            font-family: var(--serif);
            font-size: clamp(1.5rem, 3.5vw, 3rem);
            letter-spacing: 0.08em;
            line-height: 1.45;
            color: rgba(240, 236, 229, 0.84);
        }

        .atmosphere__line.is-active {
            opacity: 1;
            transform: translateY(calc(-50% - 0.2rem));
        }

        .atmosphere__line small {
            display: block;
            margin-top: 0.9rem;
            font-family: var(--sans);
            font-size: 0.74rem;
            letter-spacing: 0.26em;
            text-transform: uppercase;
            color: var(--muted-deep);
        }

        .preview {
            padding-top: 3rem;
        }

        .preview__copy {
            max-width: min(100%, 960px);
            margin: 0 auto 2rem;
        }

        .preview__frame {
            max-width: 860px;
            margin: 0 auto;
            padding: clamp(1.6rem, 3vw, 2.6rem);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
        }

        .preview__label {
            display: flex;
            align-items: baseline;
            justify-content: space-between;
            gap: 1rem;
            flex-wrap: wrap;
            margin-bottom: 1.35rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid var(--line);
        }

        .preview__label strong,
        .preview__label span {
            letter-spacing: 0.18em;
            text-transform: uppercase;
            font-size: 0.74rem;
            color: var(--muted);
            font-weight: 500;
        }

        .excerpt {
            max-width: 38rem;
            margin: 0 auto;
            font-family: var(--serif);
        }

        .excerpt p {
            color: rgba(233, 229, 222, 0.9);
            font-size: clamp(1.05rem, 2.2vw, 1.2rem);
            line-height: 2.02;
        }

        .excerpt p:first-of-type::first-letter {
            float: left;
            margin-right: 0.14em;
            font-size: 4.5rem;
            line-height: 0.88;
            color: rgba(240, 236, 229, 0.95);
        }

        .download__panel {
            display: grid;
            grid-template-columns: minmax(220px, 320px) minmax(0, 1fr);
            gap: clamp(1.5rem, 4vw, 3rem);
            padding: clamp(1.4rem, 3vw, 2rem);
            align-items: center;
        }

        .download__cover {
            position: relative;
            width: min(100%, 300px);
            margin: 0 auto;
            border-radius: 22px;
            overflow: hidden;
            box-shadow: 0 22px 46px rgba(0, 0, 0, 0.35);
            border: 1px solid rgba(255, 255, 255, 0.12);
        }

        .download__cover::after {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(180deg, rgba(255, 255, 255, 0.08), transparent 28%, rgba(0, 0, 0, 0.14));
        }

        .download__actions {
            margin-top: 1.75rem;
            display: flex;
            flex-wrap: wrap;
            gap: 1rem;
            align-items: center;
        }

        .button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-height: 3.3rem;
            padding: 0.95rem 1.45rem;
            border-radius: 999px;
            border: 1px solid rgba(213, 181, 141, 0.38);
            background: linear-gradient(180deg, rgba(213, 181, 141, 0.16), rgba(213, 181, 141, 0.07));
            box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.08), 0 16px 28px rgba(0, 0, 0, 0.18);
            color: #f1ebe2;
            font-size: 0.82rem;
            letter-spacing: 0.22em;
            text-transform: uppercase;
            transition: transform 180ms ease, border-color 180ms ease, background-color 180ms ease;
        }

        .button:hover,
        .button:focus-visible {
            transform: translateY(-2px);
            border-color: rgba(213, 181, 141, 0.58);
            background: linear-gradient(180deg, rgba(213, 181, 141, 0.2), rgba(213, 181, 141, 0.11));
        }

        .download__meta {
            font-size: 0.78rem;
            letter-spacing: 0.16em;
            text-transform: uppercase;
            color: var(--muted-deep);
        }

        .closing {
            min-height: 68svh;
            display: grid;
            place-items: center;
            text-align: center;
        }

        .closing__stack {
            display: grid;
            gap: 0.6rem;
        }

        .closing__stack span {
            font-family: var(--serif);
            font-size: clamp(2rem, 5vw, 4.8rem);
            line-height: 1.08;
            letter-spacing: 0.08em;
        }

        .closing__stack span:last-child {
            color: rgba(240, 236, 229, 0.98);
        }

        .closing__note {
            max-width: 34rem;
            margin: 1.75rem auto 0;
        }

        .footer {
            width: min(100%, var(--content));
            margin: 0 auto;
            padding: 0 1.2rem 3rem;
            text-align: center;
            color: var(--muted-deep);
            font-size: 0.88rem;
            letter-spacing: 0.12em;
            text-transform: uppercase;
        }

        .visually-hidden {
            position: absolute;
            width: 1px;
            height: 1px;
            padding: 0;
            margin: -1px;
            overflow: hidden;
            clip: rect(0, 0, 0, 0);
            white-space: nowrap;
            border: 0;
        }

        .reveal {
            opacity: 0;
            transform: translateY(28px);
            transition: opacity 900ms ease, transform 900ms ease;
        }

        .reveal.is-visible {
            opacity: 1;
            transform: translateY(0);
        }

        @keyframes titleRise {
            from {
                opacity: 0;
                transform: translateY(18px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes titleBreath {
            0%,
            100% {
                opacity: 0.94;
            }
            50% {
                opacity: 1;
            }
        }

        @keyframes mistDrift {
            from {
                transform: translate3d(-1.5%, 0, 0) scale(1.02);
            }
            to {
                transform: translate3d(1.5%, -1.5%, 0) scale(1.08);
            }
        }

        @keyframes grainShift {
            0% {
                transform: translate(0, 0);
            }
            25% {
                transform: translate(-0.4%, 0.4%);
            }
            50% {
                transform: translate(0.35%, -0.25%);
            }
            75% {
                transform: translate(-0.15%, -0.35%);
            }
            100% {
                transform: translate(0, 0);
            }
        }

        @media (max-width: 820px) {
            .section-grid,
            .download__panel {
                grid-template-columns: 1fr;
            }

            .premise__aside {
                padding-top: 0;
            }

            .site-header__inner {
                align-items: start;
            }

            .hero__title {
                letter-spacing: 0.22em;
                text-indent: 0.22em;
            }

            .atmosphere__wrap {
                min-height: 280px;
            }
        }

        @media (max-width: 560px) {
            .site-header__inner,
            .preview__label,
            .site-header__links {
                flex-direction: column;
                align-items: flex-start;
            }

            .site-header__links {
                gap: 0.7rem;
            }

            .hero {
                padding-top: 8.5rem;
            }

            .hero__title {
                font-size: clamp(2.4rem, 16vw, 4.1rem);
                line-height: 1.02;
            }

            .button {
                width: 100%;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            html {
                scroll-behavior: auto;
            }

            *,
            *::before,
            *::after {
                animation: none !important;
                transition: none !important;
            }

            .reveal,
            .hero__title,
            .atmosphere__line {
                opacity: 1 !important;
                transform: none !important;
            }
        }
    </style>
</head>
<body>
    <div class="site-shell">
        <header class="site-header" data-header>
            <div class="site-header__inner">
                <a class="site-header__brand" href="#top">There Is No They</a>
                <nav class="site-header__links" aria-label="External links">
                    <a href="#preview">Chapter 1</a>
                    <a href="There Is No They.pdf">PDF</a>
                    <a href="https://github.com/joshSzep/there-is-no-they" target="_blank" rel="noreferrer">GitHub</a>
                    <a href="https://joshszep.com" target="_blank" rel="noreferrer">Author Site</a>
                </nav>
            </div>
        </header>

        <section class="hero" id="top" aria-label="Hero">
            <div class="hero__image" aria-hidden="true"></div>
            <div class="hero__veil" aria-hidden="true"></div>
            <div class="hero__mist" aria-hidden="true"></div>
            <div class="hero__mist hero__mist--two" aria-hidden="true"></div>
            <div class="hero__content">
                <h1 class="hero__title">There Is No They</h1>
                <div class="hero__meta">
                    <p class="hero__author">Joshua Szepietowski</p>
                    <p class="hero__line">A quiet literary science fiction novel about fog, failed translation, and the distance language cannot cross.</p>
                </div>
            </div>
            <a class="hero__anchor" href="#premise">Enter the fog</a>
        </section>

        <main>
            <section class="section reveal" id="premise">
                <div class="section-grid">
                    <div class="section-copy">
                        <div class="eyebrow">The Premise</div>
                        <h2>The signal answers with elegant wrongness.</h2>
                        <p>In the hiss behind the universe, there are patterns. Not one language. Not one speaker. Only local agreements, already vanishing into distance.</p>
                        <p>A man who has spent his life moving between languages discovers that understanding can fail without noise, without spectacle, without even sounding wrong. It can fail cleanly. It can fail in the shape of perfect explanation.</p>
                        <p>What breaks is not a machine. It is the older faith beneath the work: the belief that meaning survives the crossing from one mind to another.</p>
                    </div>
                    <aside class="premise__aside">
                        <div class="premise__card">
                            <p>Alien voices are not silent. They are plural, overlapping, and unreachable. The dread is not what waits in the dark. The dread is that reality is already speaking, and speech is not enough.</p>
                        </div>
                    </aside>
                </div>
            </section>

            <section class="section atmosphere reveal" aria-labelledby="atmosphere-title">
                <div class="atmosphere__wrap" data-rotator>
                    <div class="eyebrow" id="atmosphere-title">Atmosphere</div>
                    <div class="atmosphere__line is-active">fog against the glass<small>the world disappears a piece at a time</small></div>
                    <div class="atmosphere__line">coffee gone cold beside the cursor<small>attention held where it should not be</small></div>
                    <div class="atmosphere__line">a sentence that makes the wrong picture<small>false understanding, kind and catastrophic</small></div>
                    <div class="atmosphere__line">a bridge visible only in fragments<small>connection imagined, distance remaining</small></div>
                    <div class="atmosphere__line">voices everywhere, none of them for us<small>the horror of plenitude</small></div>
                    <div class="atmosphere__line">a hand held across a gap that stays real<small>love reaching anyway</small></div>
                </div>
            </section>

            <section class="section preview reveal" id="preview">
                <div class="preview__copy">
                    <div class="eyebrow">First Chapter Preview</div>
                    <h2>From The Fog</h2>
                    <p class="preview__intro">The novel opens in a room narrowed by weather, grief, and a problem that has outlived its explanation. This excerpt is pulled directly from Chapter 01 at build time.</p>
                </div>
                <div class="preview__frame">
                    <div class="preview__label">
                        <strong>Chapter 01</strong>
                        <span>The Fog</span>
                    </div>
                    <article class="excerpt" aria-label="Excerpt from Chapter 01">
EOF

cat "$EXCERPT_HTML" >> "$INDEX_FILE"

cat >> "$INDEX_FILE" <<'EOF'
                    </article>
                </div>
            </section>

            <section class="section reveal" id="download">
                <div class="download__panel">
                    <figure class="download__cover">
                        <img src="cover.png" alt="There Is No They cover" loading="lazy">
                    </figure>
                    <div class="download__copy">
                        <div class="eyebrow">Download</div>
                        <h2>A book about what cannot be carried intact.</h2>
                        <p>Read the full novel as a free PDF. No mailing list. No funnel. Just the work itself, offered into the distance.</p>
                        <p>The page is quiet on purpose. The book is not asking to be optimized. It is asking to be encountered.</p>
                        <div class="download__actions">
                            <a class="button" href="There Is No They.pdf" download>Download the Book (Free PDF)</a>
                        </div>
                    </div>
                </div>
            </section>

            <section class="section closing reveal" aria-labelledby="closing-title">
                <div>
                    <div class="eyebrow">Closing</div>
                    <h2 id="closing-title" class="visually-hidden">Closing</h2>
                    <div class="closing__stack" aria-hidden="true">
                        <span>There is no shared language.</span>
                        <span>There is no final translation.</span>
                        <span>There is no they.</span>
                    </div>
                    <p class="closing__note">What remains is the reaching: a signal offered without guarantee, a song carried into fog, a listener arriving with the wrong picture and staying anyway.</p>
                </div>
            </section>
        </main>

        <footer class="footer">There Is No They · Joshua Szepietowski</footer>
    </div>

    <script>
        (() => {
            const revealNodes = document.querySelectorAll('.reveal');
            const header = document.querySelector('[data-header]');
            const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

            const observer = new IntersectionObserver((entries) => {
                for (const entry of entries) {
                    if (entry.isIntersecting) {
                        entry.target.classList.add('is-visible');
                        observer.unobserve(entry.target);
                    }
                }
            }, {
                threshold: 0.16,
                rootMargin: '0px 0px -8% 0px'
            });

            revealNodes.forEach((node) => observer.observe(node));

            const syncHeader = () => {
                const progress = Math.min(window.scrollY / Math.max(window.innerHeight * 0.32, 1), 1);
                header.classList.toggle('is-scrolled', progress > 0.08);
                header.style.opacity = String(0.96 - (progress * 0.18));
            };

            syncHeader();

            let ticking = false;
            window.addEventListener('scroll', () => {
                if (ticking) {
                    return;
                }

                ticking = true;
                window.requestAnimationFrame(() => {
                    syncHeader();
                    ticking = false;
                });
            }, { passive: true });

            if (!prefersReducedMotion) {
                const lines = Array.from(document.querySelectorAll('[data-rotator] .atmosphere__line'));
                let activeIndex = 0;

                window.setInterval(() => {
                    lines[activeIndex].classList.remove('is-active');
                    activeIndex = (activeIndex + 1) % lines.length;
                    lines[activeIndex].classList.add('is-active');
                }, 4300);
            }
        })();
    </script>
</body>
</html>
EOF

echo "Website built: $OUTPUT_DIR"
echo "Entry point: $INDEX_FILE"
echo "Assets: $OUTPUT_COVER, $OUTPUT_PDF"