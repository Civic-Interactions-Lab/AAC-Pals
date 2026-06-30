# UI Context

## Theme

Light mode by default. The design language is clean, high-contrast, and accessible — large tap targets, bold pictogram tiles, and clear color coding based on the Fitzgerald Key system. Designed for users with motor and cognitive differences, so clarity and simplicity take priority over visual complexity.

## Fitzgerald Key Colors

The Fitzgerald Key is the core color system for AAC word categories.

| Category   | Color       | Usage                        |
| ---------- | ----------- | ---------------------------- |
| People     | Yellow      | Pronouns, names              |
| Verbs      | Green       | Action words                 |
| Descriptors| Blue        | Adjectives, adverbs          |
| Nouns      | Orange/Tan  | Objects, places, things      |
| Social     | Pink/Purple | Greetings, social phrases    |
| Other      | White/Gray  | Prepositions, conjunctions   |

## Typography

| Role          | Style                          |
| ------------- | ------------------------------ |
| Word tile label | System font, bold, large      |
| Sentence bar  | System font, regular, medium   |
| Admin UI      | System font, regular           |

Use Dynamic Type where possible so the app respects user accessibility font size settings.

## Layout Patterns

- **Word Grid**: Full-screen grid of pictogram tiles, paginated. Fixed tile size regardless of word count.
- **Sentence Bar**: Fixed bottom strip showing selected words; Speak and Clear buttons on the right.
- **Admin Panel**: Modal overlay or pushed navigation stack, separate from the AAC board.
- **Modals**: Sheet or full-screen cover depending on complexity. Used for room editing, beacon pairing, analytics.
- **User Selector**: Card-based grid of student profiles shown at app launch.

## Tile Sizing

Tiles must be large enough for users with motor difficulties. Minimum tap target: 60×60pt. On iPad, prefer 3–5 columns depending on orientation.

## Icons & Pictograms

- Pictograms sourced from ARASAAC image library (fetched by word/concept ID)
- SF Symbols used for admin UI controls only
- No decorative icons in the AAC board — every image is a communication symbol
