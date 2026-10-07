# ~/.dotfiles

[![Build Status](https://github.com/loliee/dotfiles/actions/workflows/lint.yml/badge.svg)](https://github.com/loliee/dotfiles/actions)

This repository contains my personal configuration files and setup scripts.
Feel free to browse for inspiration, but these are tailored for my workflow and environment.

## Getting Started

Clone the repository:

```bash
git clone https://github.com/loliee/dotfiles ~/.dotfiles
```

Alternatively, download as a tarball:

```bash
mkdir -p ~/.dotfiles
curl -L https://github.com/loliee/dotfiles/tarball/main \
  | tar -xzv -C ~/.dotfiles --strip-components 1 --exclude={README.md}
```

## Installation

Dotfiles and packages are managed using `make` and `stow`.

### Common Commands

- **make install**: Installs all required packages and dotfiles. On a new Mac, see [First install](#first-install).
- **make install-dotfiles**: Installs only the dotfiles, skipping packages.
- **make help**: Lists all available `make` commands with descriptions.

### First install

On a new Mac, `.brew` and mise check the GitHub artifact attestations of what they install from the start, and the
GitHub API only serves them to an authenticated user. Export a GitHub token first, then install everything:

1. Create a [GitHub token](#github-token) and export it in the current shell for both Homebrew and mise. `read -rs`
   keeps it off the screen and out of the shell history:

   ```bash
   read -rs HOMEBREW_GITHUB_API_TOKEN && export HOMEBREW_GITHUB_API_TOKEN MISE_GITHUB_TOKEN="$HOMEBREW_GITHUB_API_TOKEN"
   ```

2. Install the packages, the dotfiles, the mise tools and the git hooks:

   ```bash
   make install
   ```

`.brew` stops at once if the token is missing. Homebrew installs `gh` without checking it, since `gh` is what checks
every other bottle.

Then set fish as the [default shell](#fish-shell), and export the token at each login.

### GitHub token

Create it on GitHub, in **Settings → Developer settings → Personal access tokens → Fine-grained tokens → Generate new
token**:

- **Token name**: the name of the Mac.
- **Expiration**: 1 year.
- **Resource owner**: your account.
- **Repository access**: **Public repositories**. GitHub then shows no permission to add, and none is needed: reading
  public repositories is enough to verify attestations.

Two variables carry it, each named for its tool, so that the many programs reading `GITHUB_TOKEN` or `GH_TOKEN` do not
get it:

| Variable                    | Read by                          | For                                                                                 |
| --------------------------- | -------------------------------- | ----------------------------------------------------------------------------------- |
| `MISE_GITHUB_TOKEN`         | mise                             | attestations (`locked_verify_provenance`) and the GitHub API rate limit             |
| `HOMEBREW_GITHUB_API_TOKEN` | Homebrew, which hands it to `gh` | bottle attestations (`HOMEBREW_VERIFY_ATTESTATIONS`, set by `.brew` and the shells) |

I keep the token in 1Password, and `opx` exports both variables at login from its RAM disk (`env_key` entries).

## macOS Setup

My macOS setup scripts apply personal preferences and security tweaks:

```bash
make setup-macos
make setup-macos-hardening
```

## Fish Shell

Set Fish as default shell (macOS example):

```bash
echo "$(brew --prefix)/bin/fish" | sudo tee -a /etc/shells
chsh -s "$(brew --prefix)/bin/fish"
```

## Resources

- [Apple Official manual page](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/defaults.1.html)
- [OS X Security and Privacy Guide](https://github.com/drduh/OS-X-Security-and-Privacy-Guide#http)

---

> **Note:** These dotfiles are not intended as a plug-and-play solution for others.
> Please review and modify for your own needs before using.
