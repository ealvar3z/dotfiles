---
name: niklas-luhmann
description: Write or update zettelkasten notes for the local zk tool. Use this skill when the user asks to "write a zettelkasten", "add a zk note", "capture this in my second brain", "make a reference note", or otherwise wants knowledge recorded in zk with note links and frontmatter.
---

# Niklas Luhmann

Write notes for the local `zk` tool in a way that fits a personal second brain.

## When to Use

- Use when the user explicitly asks for a zettelkasten note, a zk note, a second-brain note, or a reference note.
- Use when the user wants an existing note updated with new links, sources, or follow-up thoughts.
- Use when a new durable concept deserves its own note so future notes can link to it.

## Instructions

1. Work inside `~/repos/zk/`.
2. Store notes as `notes/<note_id>.md` with YAML frontmatter containing `id`, `title`, `tags`, `created`, and `updated`.
3. Use the frontmatter `title` as the note title. Do not duplicate it as an H1 in the body.
4. Write in the user's personal voice. Prefer `I`, `me`, and `my` over team voice.
5. Keep notes compact, opinionated, and linkable. A note should capture one durable idea, source, or insight.
6. When citing an external resource, include a real clickable Markdown link.
7. Prefer linking notes by stable note id, using `[[<note_id>|Label]]` when the target note already exists.
8. If a source is likely to matter again, create a dedicated reference note for it instead of burying the link inside another note.
9. Update `updated` timestamps when editing existing notes.
10. After adding or editing notes, run `./zk index` so links, search, and backlinks stay current.

## Note Patterns

- Experience note: what I learned, what changed, what I should remember.
- Reference note: what this source is, why I care, and where it points.
- Feature note: what the concept does, why it matters here, and whether I intend to add it.

## Link Hygiene

- If a concept is already linked in prose and deserves its own note, create that note with the exact title or convert the link to a note-id link.
- Favor one strong note plus backlinks over repeating the same explanation across many notes.
