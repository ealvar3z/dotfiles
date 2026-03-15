---
name: compose-blog-post
description: Compose a blog post in plaintext format for ptb. Use this skill when the user wants to write or draft a new post for the blog; follow existing style (title, optional ASCII art, images, links, closing).
---

# Compose blog post

Compose a blog post in plaintext for the ptb blog. **Use the previous posts as template files** under `~/repos/ptb/txt/`. Do not create or edit `.html` files (those are generated from templates). Keep the skill generic so it works for any topic (how-to, review, setup, list, etc.).

## When to Use

- Use when the user wants to write or draft a new blog post for ptb.
- Use when they describe a topic, share notes, or ask to "write a post about X".

## Instructions

1. **Match existing style.** Read 2–3 recent posts from `~/repos/ptb/txt/*.txt`:

2. **Decide filename and date.** Use `YYYYMMDD_slug-slug.txt` for the template file. Ask for the publish date and slug if the user doesn't specify them.

3. **Structure the post** in this order:
   - TITLE.
   - Optional: ASCII art in a fenced code block (triple backticks). Suggest only if it fits the topic (e.g. diagram, device, logo).
   - Short intro paragraph(s)
   - all paragraph(s) should fit within 80 columns

4. **plaintext conventions.**
   - Code blocks: triple backticks; list blocks with `*` or `-`.
   - Use HTML href links for actual links; otherwise, plain plaintext only. When in doubt, study the previous `.txt` blog posts.

5. **Ask when unclear.** If the topic, date, slug, or need for ASCII art / images / related posts is missing, ask the user before writing.
