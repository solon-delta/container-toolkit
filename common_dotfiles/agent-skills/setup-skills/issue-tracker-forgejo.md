# Issue tracker: Forgejo

Issues and PRDs for this repo live as Forgejo issues. Use the `fj` CLI for all operations.

## Conventions

- **Create an issue**: `fj issue create --body "..." <title>`. Use a heredoc for multi-line bodies.
- **Read an issue**: `fj issue view <number> body`, for an issues title and body. Use subcommands `... comments` to list every comment, and `... comment <idx>` for a specific comment.
- **List issues**: `fj issue search --state open --labels <labels>` with appropriate `--labels` and `--state` filters.
- **Comment on an issue**: `fj issue comment <number> "..."`
- **Apply / remove labels**: `fj issue edit <number> labels --add "..."` / `--rm "..."`
- **Close**: `gh issue close <number> --with-msg "..."`

Infer the repo from `git remote -v` — `fj` does this automatically when run inside a clone.

## When a skill says "publish to the issue tracker"

Create a Forgejo issue.

## When a skill says "fetch the relevant ticket"

Run `fj issue view <number>`.
