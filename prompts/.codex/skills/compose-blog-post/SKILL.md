---
name: compose-blog-post
description: Compose a blog post in plaintext format for ptb. Use this skill when the user wants to write or draft a new post for the blog; follow existing style (title, optional ASCII art, images, links, closing).
---

# Compose blog post

Compose a blog post in plaintext for the ptb blog. Read the current repo first and treat existing posts under `txt/*.txt` as the source of truth. Do not create or edit `.html` files; `ptb` generates those from the plaintext sources and templates.

## When to Use

- Use when the user wants to write or draft a new blog post for ptb.
- Use when they describe a topic, share notes, or ask to "write a post about X".

## Instructions

1. **Match the current repo.**
   Read 2-3 recent posts from `txt/*.txt` in the current checkout before writing anything. Re-check the repo if you are unsure because the format is intentionally minimal and may evolve.

2. **Respect the filename contract.**
   Use `txt/YYYYMMDD_slug-slug.txt`.
   The date comes from the `YYYYMMDD` prefix.
   The output HTML filename comes from the slug part only, for example `txt/20260217_local-vimrc-exrc-nosecure.txt` becomes `output/local-vimrc-exrc-nosecure.html`.
   The index and RSS ordering are driven by the filename date, not by any in-file metadata.

3. **Understand how titles work in this repo.**
   The generated HTML page title and `<h1>` come from the filename slug, not from the first line of the post body.
   The first line inside the `.txt` file is still usually a visible headline, often uppercase, but it is content, not metadata.
   Keep the filename slug concise and readable because it becomes the browser title, index entry, RSS title, and output HTML name.

4. **Write for `<pre>` rendering.**
   `ptb` injects the entire file body into `<pre>{{ .Content | safeHTML }}</pre>`.
   Preserve deliberate whitespace, indentation, and line breaks.
   Keep prose wrapped to roughly 80 columns unless the post intentionally uses a wider layout for tables or diagrams.
   Plain text, ASCII diagrams, lightweight lists, and fenced code blocks all work well here.
   Raw HTML is allowed and used in existing posts, especially `<a href="...">...</a>` links.
   Angle-bracket autolinks such as `<https://example.com>` also appear in the repo.
   Avoid adding frontmatter, Markdown headings, or metadata blocks unless the repo format changes.

5. **Follow the observed house style.**
   Common patterns in this repo:
   - an all-caps opening line as the visible post heading
   - short paragraphs with deliberate spacing
   - plain lists using `-`
   - occasional fenced `text` code blocks for diagrams or quoted material
   - occasional sign-offs such as `- Welcome.` or `- Mata ne!`
   Do not force every post into the same voice, but keep the minimal plaintext aesthetic.

6. **When creating a post, update only the source text file unless asked otherwise.**
   Do not hand-author files in `output/`.
   If the user asks you to verify rendering, run the repo's normal generation command after writing the post.

7. **Ask only for missing decisions that materially affect the filename or content.**
   If the user did not specify the publish date or slug, ask or make a clearly stated reasonable assumption when the workflow allows it.
   If they only want a draft, you can provide the plaintext body first and propose a filename separately.
