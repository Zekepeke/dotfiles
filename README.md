# dotfiles

Personal terminal setup for macOS: [WezTerm](https://wezterm.org) + [tmux](https://github.com/tmux/tmux) + [Neovim](https://neovim.io).

Managed with [GNU Stow](https://www.gnu.org/software/stow/) — the real files live in this repo and are symlinked into `$HOME`, so editing `~/.tmux.conf` edits the tracked file directly.

## Layout

Each top-level directory is a Stow "package" whose inner structure mirrors `$HOME`:

```
dotfiles/
├── tmux/
│   └── .tmux.conf              → ~/.tmux.conf
├── wezterm/
│   └── .wezterm.lua            → ~/.wezterm.lua
└── nvim/
    └── .config/
        └── nvim/               → ~/.config/nvim
            ├── init.lua
            ├── lazy-lock.json
            └── lua/plugins/
                ├── colorscheme.lua
                └── markdown.lua
```

## Setting up a new Mac

### 1. Command line tools and Homebrew

```bash
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

On Apple Silicon, add Homebrew to the path for the current shell (the installer prints this too):

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### 2. Install the programs these configs assume

```bash
brew install stow git neovim tmux ripgrep node gh
brew install --cask wezterm
```

- `ripgrep` backs `:grep` and the Snacks grep picker
- `node` is required by `markdown-preview.nvim`, which runs `yarn install` at build time
- `gh` is optional, for GitHub auth

### 3. Install the fonts

WezTerm is configured for `MesloLGS Nerd Font Mono` with a `Symbols Nerd Font Mono` fallback, and the tab bar uses `Hack Nerd Font`. Neovim's devicons and markdown heading glyphs need a Nerd Font too — without these you'll get tofu boxes everywhere.

```bash
brew install --cask font-meslo-lg-nerd-font font-hack-nerd-font font-symbols-only-nerd-font
```

### 4. Authenticate with GitHub

```bash
gh auth login
```

Or set up an SSH key manually and add it at <https://github.com/settings/keys>.

### 5. Clone and stow

```bash
git clone git@github.com:Zekepeke/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow -t ~ tmux wezterm nvim
```

Stow prints nothing on success. Verify:

```bash
ls -la ~/.tmux.conf ~/.wezterm.lua ~/.config/nvim
```

Each should show an arrow pointing back into `~/dotfiles`.

### 6. First launch

```bash
nvim
```

lazy.nvim bootstraps itself, then installs every plugin at the exact commits pinned in `lazy-lock.json`. Let it finish. `markdown-preview.nvim` takes the longest since it runs a `yarn install`.

Then open WezTerm and run `tmux`. Everything should look and behave like the old machine.

## If Stow reports a conflict

Stow refuses to link when a real file already sits at the target. A fresh Mac usually has none, but launching Neovim before stowing will create `~/.config/nvim`.

Remove the conflicting file if it's just a default:

```bash
rm -rf ~/.config/nvim
stow -t ~ nvim
```

## Day-to-day use

Because the files are symlinked, editing config through the normal paths edits the repo:

```bash
nvim ~/.tmux.conf     # same file as ~/dotfiles/tmux/.tmux.conf
cd ~/dotfiles
git add -A && git commit -m "tmux: ..." && git push
```

Pull changes on the other machine with `git pull` — no re-stowing needed, the symlinks already point at the files.

Commit `lazy-lock.json` whenever plugins are updated (`:Lazy update`), so both machines stay on identical plugin versions.

## Adding a new package

Mirror the path the file has relative to `$HOME`, then stow it:

```bash
mkdir -p ~/dotfiles/zsh
mv ~/.zshrc ~/dotfiles/zsh/
stow -t ~ zsh
```

For something under `~/.config`, the package needs the `.config` level inside it — e.g. `~/dotfiles/starship/.config/starship.toml`.

## Removing links

```bash
cd ~/dotfiles
stow -D -t ~ tmux wezterm nvim
```

This deletes the symlinks only. The real files stay in the repo.

## Notes on what's configured

**tmux** — prefix is `C-s`, panes and windows are 1-indexed, mouse on, vi copy mode with drag-to-select piping to `pbcopy`. `|` and `-` (also `;` and `'`) split panes in the current directory, `M-arrows` move between panes, `M-w` kills one, `prefix r` reloads the config.

**WezTerm** — Chalk color scheme, 80% opacity with background blur, 16pt Meslo. `Cmd-a` selects the entire scrollback.

**Neovim** — lazy.nvim, kanagawa-wave colorscheme, Copilot with `Tab` to accept, Snacks pickers (`C-f` files, `<leader>s` grep, `<leader>e` explorer), and markdown rendering plus browser preview (`<leader>mt`, `<leader>mp`). Leader is space.
