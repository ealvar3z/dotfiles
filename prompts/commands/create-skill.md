# /create-skill

**Description:** Create a canonical Codex skill in the Stow-managed dotfiles source tree.

**Parameters:**
- `skill_name`: lowercase letters, digits, and hyphens only

**Example usage:**
- `/create-skill docker-compose`
- `/create-skill rust-conventions`

---

## Prompt

Use the `skill-creator` skill to create `{{skill_name}}`.

1. Treat `~/dotfiles/prompts/.codex/skills` as the source directory. Do not
   create the skill directly under `~/.codex/skills`.
2. Read the complete `skill-creator` instructions and clarify only decisions
   that materially change the skill.
3. Initialize the skill with the official `init_skill.py`, including only the
   resource directories it needs.
4. Write canonical `SKILL.md` frontmatter containing `name` and `description`.
   Put all trigger conditions in the description.
5. Generate `agents/openai.yaml` with quoted `display_name`,
   `short_description`, and a `default_prompt` that explicitly mentions
   `$skill-name`.
6. Remove every initializer placeholder and avoid auxiliary README, changelog,
   or installation files inside the skill.
7. Run the official `quick_validate.py` validator, using PyYAML through `uv`
   when needed.
8. Confirm that Codex has initialized `~/.codex/skills`, then run:

   ```sh
   cd ~/dotfiles
   stow -t ~ prompts
   ```

9. Verify that `~/.codex/skills/{{skill_name}}` resolves to the dotfiles source
   and report the files created.
