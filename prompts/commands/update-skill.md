# /update-skill

**Description:** Update a Stow-managed Codex skill and keep its canonical metadata valid.

**Parameters:**
- `skill_name`: the existing skill directory name

**Example usage:**
- `/update-skill go-best-practices`
- `/update-skill compose-blog-post`

---

## Prompt

Use the `skill-creator` skill to update `{{skill_name}}`.

1. Read the skill from
   `~/dotfiles/prompts/.codex/skills/{{skill_name}}/SKILL.md`. If it does not
   exist, list the managed skill directories and stop.
2. Read the complete `skill-creator` instructions and inspect the skill's
   references, scripts, assets, and `agents/openai.yaml`.
3. Make the requested change in the dotfiles source tree. Keep trigger
   conditions in the frontmatter description and keep the body concise.
4. Regenerate `agents/openai.yaml` when the skill name, purpose, or default
   invocation changes.
5. Run the official `quick_validate.py` validator and check every relative
   resource link.
6. Run `stow -t ~ prompts` from `~/dotfiles` and verify that the installed
   canonical path resolves back to the updated source.
7. Show the resulting diff and validation result.
