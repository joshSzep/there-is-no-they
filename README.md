# There Is No They

![Cover](cover.png)

**Joshua Szepietowski**

A literary science fiction novel about the impossibility of lossless transmission.

---

## About

In 2032, a computational error revealed that the cosmic background radiation—the hiss filtered out by every radio telescope—contains alien transmissions. Countless sources. Overlapping. Ancient and recent. Humanity had been bathed in it for decades and called it noise.

Tomasz Kowalski, a Polish xenolinguist, spends eight years decoding one signal. He succeeds. Then he applies his model to another signal, and it fails—cleanly, elegantly, catastrophically. The first wasn't a key to the cosmos. It was a local agreement between minds that no longer exist.

There is no single alien language. No unified "they." No canonical system to decode.

The universe is not silent. It is cacophonous. And none of it translates.

---

## Structure

A memoir written in 2063 by a man whose discovery broke the Signal Translation Project—and his marriage—twenty years earlier.

**Two temporal layers:**

- **2063:** Tom at 62, alone in Oakland, writing instead of flying to Kraków where his mother is dying.
- **2043:** The year of the breakthrough, the failure, and the slow collapse of everything he thought he understood.

Five parts. Twenty-five chapters. ~53,000 words.

---

## Themes

- **The impossibility of lossless transmission** — meaning cannot be moved without loss
- **The violence of compression** — systems that require summaries, narratives, a coherent "they"
- **The cost of seeing** — insight as exile, understanding as isolation
- **False understanding** — the cruelty of being understood incorrectly
- **The horror of plenitude** — surrounded by meaning, none of it reachable

---

## Repository Structure

```
├── chapters/
│   ├── Part 1 - Before/
│   ├── Part 2 - The Break/
│   ├── Part 3 - The Distance/
│   ├── Part 4 - The Institution/
│   └── Part 5 - Collapse/
├── notes/
│   ├── characters/
│   └── world/
├── scripts/
│   └── build-manuscript.sh
├── MANUSCRIPT.md
└── AGENTS.md
```

## Building

To compile the manuscript from chapter files:

```bash
./scripts/build-manuscript.sh
```

This generates `MANUSCRIPT.md` at the repository root.
