---
name: update-blog-post
description: Update an existing blog post in .txt format from ptb, commit, push, and optionally publish.
---

# Update blog post

Update an existing blog post in `~/repos/ptb/txt/` in the git repository in `~/repos/ptb/`

## When to Use

- Use this skill when the user wants to edit or update an existing blog post on ptb.

## Instructions

1. Identify the blog post file in `~/repos/ptb/txt/` matching the name or slug given by the user. If multiple matches exist, ask which one.
2. Read the matched `.txt` file to understand its current content.
3. If the user hasn't specified what to update, ask what changes should be made.
4. Apply the requested changes while preserving the existing plaintext style and structure. Also add an updated note before the new or modified text like this "> Updated Tue 27 Jan: Added SECTION about SHORT DESCRIPTION here"
5. Also add an "last updated" note to the blog post's publishing date, format like this  "> Published at 2025-07-13T16:44:29+03:00, last updated Tue 27 Jan 10:09:08 EET 2026"
6. Show a diff or summary of the changes before writing.
7. After writing, commit and push the changes to git.
