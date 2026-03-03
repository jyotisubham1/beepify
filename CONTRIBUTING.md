# Contributing to beepify

## Workflow
1. Fork the repo
2. Create a branch from `dev`
3. Make your changes
4. Push and open a PR targeting `dev` (NOT main)
5. Wait for review and approval

## Branch Naming
| Type | Pattern | Example |
|------|---------|---------|
| Feature | `feature/xxx` | `feature/linux-installer` |
| Bug fix | `fix/xxx` | `fix/sound-not-playing` |
| Docs | `docs/xxx` | `docs/update-readme` |
| Chore | `chore/xxx` | `chore/cleanup-scripts` |

## Commit Messages
- `feat: add linux sound support`
- `fix: correct sound path on windows`
- `docs: update contributing guide`
- `chore: clean up gitignore`

## OS Contributions
- Mac changes → only touch `mac/` folder
- Windows changes → only touch `windows/` folder
- Linux changes → only touch `linux/` folder
- Sounds → add to `sounds/` folder only
