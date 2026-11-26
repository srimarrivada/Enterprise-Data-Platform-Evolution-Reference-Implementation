# P0-01: Repository Hygiene

| | |
|---|---|
| Phase | **0. Bootstrap** |
| Status | **Built** |
| Branch + PR | `main` _(bootstrap exception: no `main` exists yet to open a PR against)_ |
| Commit | `chore(p0-01): gitignore, gitattributes, editorconfig, license, README + status table` |
| Design | NFR-07 (no secrets in the repo). Implementation rule "Never commit" |
| Tools | Git for Windows (**Git Bash**) |

## Objective

Start a clean repository that can't leak secrets or generated data, and keeps line endings stable on Windows,
WSL and Linux containers.

## Design Decisions

- **`.gitattributes` owns line endings** (`core.autocrlf false`): Shell scripts stay LF so they run in WSL and
  containers; `.cmd`/`.ps1` stay CRLF so Windows runs them correctly.
- **Profiles are committed, secrets aren't:** `config/env/*.env` (P0-02) hold hosts and ports only; passwords
  live in `.env`, which is ignored.
- **Tableau:** `.twb` (XML, no data) is committed; `.twbx`/`.hyper` (data) are not.
- **Terraform lock files are committed** (reproducible provider versions); state and `*.tfvars` are not.
- **README links only to things that exist:** Phase folders are plain text until the step that creates them.

## Files Added

```text
.gitignore  .gitattributes  .editorconfig  LICENSE  README.md
docs/implementation/10-phase0/P0-01-repo-hygiene.md
```

## Code

<!-- include: .gitignore -->
<!-- include: .gitattributes -->
<!-- include: .editorconfig -->
<!-- include: README.md -->

## How to Run

### A. Laptop _(Git Bash)_

```bash
mkdir -p data/lake && touch .env data/lake/x.parquet && mkdir -p build && touch build/x.md
git status --short                  # only the six files above appear
git check-ignore -v .env data/lake/x.parquet build/x.md
git ls-files --eol                  # after the commit: i/lf for text files
rm -rf data build .env
```

## Expected Output

`git check-ignore -v` prints the matching `.gitignore` rule for each of the three paths. `git status` doesn't list `.env`, `data/` or `build/`.

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `warning: LF will be replaced by CRLF` | Global `core.autocrlf=true` | `git config core.autocrlf false` in this repo |
| Every file shows as modified after adding `.gitattributes` | Files committed before normalisation | `git add --renormalize . && git commit -m "chore: normalise line endings"` |
| `.sh` fails in WSL with `$'\r': command not found` | Script saved with CRLF | Re-save as LF; `.gitattributes` prevents it from now on |

## Done Checklist

- [x] `git status` clean of `.env` and `data/`
- [x] README renders on GitHub
- [x] Step chapter written 
