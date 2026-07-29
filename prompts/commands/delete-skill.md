# /delete-skill

**Description:** Remove a Stow-managed personal Codex skill safely.

**Parameters:**
- `skill_name`: the personal skill directory to remove

**Example usage:**
- `/delete-skill docker-compose`
- `/delete-skill rust-conventions`

---

## Prompt

Remove the personal skill `{{skill_name}}` from the dotfiles-managed Codex
skills tree.

1. Resolve
   `~/dotfiles/prompts/.codex/skills/{{skill_name}}` and show its frontmatter.
2. Refuse to target `.system`, plugin caches, or anything outside the personal
   dotfiles source tree.
3. Ask for explicit confirmation because removing a skill deletes its complete
   directory.
4. From `~/dotfiles`, unstow the package before deleting the source:

   ```sh
   stow -D -t ~ prompts
   ```

5. Remove only the confirmed source directory, then reinstall the remaining
   package:

   ```sh
   stow -t ~ prompts
   ```

6. Verify that `~/.codex/skills/{{skill_name}}` no longer exists, that all other
   personal skill links remain valid, and that `.system` is untouched.
7. Show the Git diff and explain how the deleted skill can be recovered from
   Git before the change is committed.
