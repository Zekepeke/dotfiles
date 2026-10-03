# dotfiles

My terminal setup: [WezTerm](https://wezterm.org) + [tmux](https://github.com/tmux/tmux) + [Neovim](https://neovim.io).
Built on macOS, and it runs on Linux and Windows (via WSL2) with a couple of small tweaks, covered below.

Managed with [GNU Stow](https://www.gnu.org/software/stow/).
The real files live in this repo and are symlinked into `$HOME`, so editing `~/.tmux.conf` edits the tracked file directly.

## Table of contents

- [How the pieces fit together](#how-the-pieces-fit-together)
- [Layout](#layout)
- [Quick start](#quick-start)
- [Setup on macOS](#setup-on-macos)
- [Setup on Linux](#setup-on-linux)
- [Setup on Windows](#setup-on-windows)
- [Trying it without breaking your own setup](#trying-it-without-breaking-your-own-setup)
- [How the symlinks work](#how-the-symlinks-work)
- [What's configured](#whats-configured)
- [Keybinding cheat sheet](#keybinding-cheat-sheet)
- [Workflow](#workflow)
- [Merge conflicts](#merge-conflicts)
- [Machine-local overrides](#machine-local-overrides)
- [Day-to-day use](#day-to-day-use)
- [Troubleshooting](#troubleshooting)

## How the pieces fit together

Each tool has one job, and they stay out of each other's way.

| Layer | Tool | Job |
| --- | --- | --- |
| Window | WezTerm | GPU terminal: fonts, colors, transparency. No tabs and no splits of its own. |
| Sessions | tmux | Sessions, windows, panes, scrollback, copy mode. Survives disconnects. |
| Editor | Neovim | Editing, LSP, completion, formatting, markdown rendering. |

WezTerm's tab bar is turned off because tmux draws the status bar.
Both WezTerm and tmux use the same palette (kanagawa) as Neovim, so everything looks like one app.

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
            ├── init.lua            options, keymaps, lazy.nvim bootstrap, Copilot, Snacks
            ├── lazy-lock.json      pinned plugin commits
            └── lua/plugins/
                ├── colorscheme.lua kanagawa-wave
                ├── git.lua         merge conflict helpers
                ├── lsp.lua         Mason, LSP, blink.cmp, treesitter, conform
                ├── markdown.lua    in-buffer rendering + browser preview
                ├── navigation.lua  smart-splits (Alt-hjkl across nvim and tmux)
                └── pdf.lua         PDF as text
```

## Quick start

If you already have the prerequisites (git, stow, Neovim 0.11+, tmux, ripgrep, node, a Nerd Font, WezTerm):

```bash
git clone https://github.com/Zekepeke/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow -t ~ tmux wezterm nvim
nvim        # let lazy.nvim install everything, then :q
tmux
```

If you don't have them yet, follow the section for your OS.

## Setup on macOS

### 1. Command line tools and Homebrew

```bash
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

On Apple Silicon, add Homebrew to the path for the current shell (the installer prints this too):

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### 2. Programs

```bash
brew install stow git neovim tmux ripgrep node gh poppler
npm install -g @mermaid-js/mermaid-cli
brew install --cask wezterm
```

### 3. Fonts

```bash
brew install --cask font-meslo-lg-nerd-font font-hack-nerd-font font-symbols-only-nerd-font
```

### 4. Clone and stow

```bash
git clone https://github.com/Zekepeke/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow -t ~ tmux wezterm nvim
```

Stow prints nothing on success.
Verify:

```bash
ls -la ~/.tmux.conf ~/.wezterm.lua ~/.config/nvim
```

Each should show an arrow pointing back into `~/dotfiles`.

### 5. First launch

```bash
nvim
```

lazy.nvim bootstraps itself, then installs every plugin at the exact commits pinned in `lazy-lock.json`.
Mason then installs the language servers (`pyright`, `clangd`, `lua_ls`) and Treesitter compiles its parsers.
Let it all finish, then restart Neovim.
`markdown-preview.nvim` takes the longest because it runs a `yarn install`.

Run `:checkhealth` once to confirm nothing is missing.

### 6. Optional: Copilot and formatters

- Copilot: run `:Copilot auth` inside Neovim and follow the prompt.
- Formatters used on save are not installed by `ensure_installed`.
  Install the ones for languages you use:

```bash
brew install stylua ruff clang-format
```

If a formatter is missing, `conform.nvim` quietly falls back to the LSP formatter.

### 7. Optional: GitHub auth

```bash
gh auth login
```

Or add an SSH key at <https://github.com/settings/keys>.
Cloning over HTTPS (as above) needs no auth.
Use the `git@github.com:` URL if you want to push.

## Setup on Linux

Tested assumptions: Debian/Ubuntu names below, adjust for your package manager.
Neovim 0.11+ is required, and distro packages are often older.
Check with `nvim --version`.

```bash
sudo apt update
sudo apt install -y git stow tmux ripgrep nodejs npm curl unzip build-essential xclip poppler-utils
```

Install a current Neovim if the packaged one is too old:

```bash
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
```

Install WezTerm from <https://wezterm.org/install/linux.html>, then install the fonts:

```bash
mkdir -p ~/.local/share/fonts && cd ~/.local/share/fonts
for f in Meslo Hack NerdFontsSymbolsOnly; do
  curl -LO "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$f.zip"
  unzip -o "$f.zip" && rm "$f.zip"
done
fc-cache -f
```

Then clone and stow exactly as in the macOS steps.

Two things are macOS-specific in the tmux config and need an override on Linux.
Create `~/.tmux.local.conf` (it is sourced last, so it wins and is not tracked):

```tmux
# X11 (xclip)
bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel "xclip -selection clipboard -i"
bind -T copy-mode    MouseDragEnd1Pane send -X copy-pipe-and-cancel "xclip -selection clipboard -i"
bind -T copy-mode-vi DoubleClick1Pane  send -X select-word \; send -X copy-pipe-and-cancel "xclip -selection clipboard -i"
bind -T copy-mode-vi TripleClick1Pane  send -X select-line \; send -X copy-pipe-and-cancel "xclip -selection clipboard -i"
```

On Wayland use `wl-copy` instead of `xclip -selection clipboard -i`.
Since `set-clipboard on` is already set, OSC 52 copy works in most modern terminals even without this.

## Setup on Windows

tmux has no native Windows build, so the recommended route is **WezTerm on Windows, with everything else inside WSL2**.
Neovim and tmux then run in a real Linux environment and behave exactly as they do in this repo.

### 1. Install WSL2 and Ubuntu

In an admin PowerShell:

```powershell
wsl --install -d Ubuntu
```

Reboot if asked, then finish the Ubuntu user setup.

### 2. Install WezTerm and the fonts on Windows

```powershell
winget install wez.wezterm
winget install --id DEVCOM.MesloLGSNerdFont -e
winget install --id DEVCOM.HackNerdFont -e
```

If winget cannot find a font, download the zips from <https://www.nerdfonts.com/font-downloads> and install them by right clicking the `.ttf` files.
Also install `Symbols Nerd Font Mono` from the same page.
Fonts must be installed on **Windows**, because WezTerm renders them, not WSL.

### 3. Inside Ubuntu: programs, clone, stow

Follow the [Linux](#setup-on-linux) steps for packages, Neovim and the clone.
Skip the font step.
Stow only `tmux` and `nvim` here:

```bash
cd ~/dotfiles
stow -t ~ tmux nvim
```

For the clipboard, either use the OSC 52 default (works through WezTerm) or add a `clip.exe` override to `~/.tmux.local.conf`:

```tmux
bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel "clip.exe"
bind -T copy-mode    MouseDragEnd1Pane send -X copy-pipe-and-cancel "clip.exe"
```

### 4. WezTerm config on the Windows side

WezTerm reads `C:\Users\<you>\.wezterm.lua`, which is outside WSL.
Copy the file over and tell WezTerm to open Ubuntu by default:

```bash
cp ~/dotfiles/wezterm/.wezterm.lua /mnt/c/Users/<you>/.wezterm.lua
```

Then add this line to that Windows copy, before `return config`:

```lua
config.default_domain = "WSL:Ubuntu"
```

The macOS-only options (`macos_window_background_blur`, the Option key settings) are ignored on Windows.
Remember the Windows copy is not a symlink, so re-copy it after editing the repo version.

### Native Windows (no WSL)

Only WezTerm and Neovim will work natively.
Neovim's config is at `%LOCALAPPDATA%\nvim`, so link or copy `nvim\.config\nvim` there.
You will also need `git`, `ripgrep`, `node` and a C compiler (for Treesitter, e.g. `zig` or `mingw`).
tmux is the missing piece, so WSL2 is the better experience.

## Trying it without breaking your own setup

If you want to test drive this on a machine that already has its own config, Neovim can run this config in isolation:

```bash
git clone https://github.com/Zekepeke/dotfiles.git ~/dotfiles-try
NVIM_APPNAME=nvim-try bash -c '
  mkdir -p ~/.config && ln -sfn ~/dotfiles-try/nvim/.config/nvim ~/.config/nvim-try
  nvim
'
```

`NVIM_APPNAME` makes Neovim use `~/.config/nvim-try` and separate data and state directories, so your real config is untouched.
For tmux, run it with a throwaway config file:

```bash
tmux -f ~/dotfiles-try/tmux/.tmux.conf -L try
```

`-L try` uses a separate server socket, so it will not attach to your existing sessions.
Delete `~/dotfiles-try` and `~/.config/nvim-try` when you are done.

## How the symlinks work

Stow creates **symbolic links** (symlinks) from your home directory back into this repo.
After `stow -t ~ tmux`, the system looks like this:

```
~/.tmux.conf  ──symlink──▶  ~/dotfiles/tmux/.tmux.conf
~/.config/nvim ─symlink──▶  ~/dotfiles/nvim/.config/nvim
```

- Programs read `~/.tmux.conf` as usual and transparently get the repo file.
- Editing either path edits the same file, so `git diff` in the repo always shows what you changed.
- Nothing is copied, so there is no drift between "the config in use" and "the config in git".
- `stow -t ~ <package>` links, `stow -D -t ~ <package>` unlinks, `stow -R -t ~ <package>` relinks.
- Stow folds directories when it can.
  `~/.config/nvim` is one link to a whole directory, which is why new files you add under it show up in the repo automatically.

Check where any link points with `ls -la ~/.tmux.conf` or `readlink ~/.config/nvim`.

### If Stow reports a conflict

Stow refuses to link when a real file already sits at the target.
Launching Neovim or tmux before stowing creates default files that get in the way.

Back up or remove the conflicting file, then stow again:

```bash
mv ~/.config/nvim ~/.config/nvim.bak
stow -t ~ nvim
```

## What's configured

### WezTerm

- Color scheme `kanagawabones`, 16pt `MesloLGS Nerd Font Mono` with a `Symbols Nerd Font Mono` fallback.
- Translucent window (70% opacity, blur 10) with only a resize border, no title bar.
- Tab bar disabled, since tmux draws it.
- Opens at 120x32, capped at 120 fps.
- Left Option sends Alt (needed for tmux `M-` bindings), right Option still composes characters.
- `Cmd-a` selects the entire scrollback by driving copy mode.

### tmux

- Prefix is `C-s` instead of `C-b`.
- Windows and panes are 1-indexed, and windows renumber when one closes.
- Mouse on, 50,000 lines of history, no escape delay, vi keys in copy mode.
- Status bar at the top, minimal: session name on the left, clock on the right, active window highlighted.
- Drag, double-click or triple-click in copy mode copies to the system clipboard via `pbcopy`.
- `set-clipboard on` also emits OSC 52, so copying works over SSH.
- Extended keys, focus events and passthrough are enabled so Neovim can see modified keys, `autoread` works, and image protocols pass through.
- `Alt-h/j/k/l` moves between panes and hands the key to Neovim when it is focused, so the same keys cross Neovim splits and tmux panes (smart-splits).
- `Alt-,` and `Alt-.` go to the previous and next window.
- `M-o` turns the outer tmux off so a nested tmux on a remote host receives the keys.
- `~/.tmux.local.conf` is sourced at the end if present.

### Neovim

Requires 0.11 or newer.

- **Plugin manager:** lazy.nvim, bootstraps itself, versions pinned in `lazy-lock.json`.
- **Colors:** kanagawa-wave.
- **Options:** relative line numbers, 4-space indent, smart-case search, system clipboard, `scrolloff=8`, ripgrep as `grepprg`.
- **Over SSH:** yank goes to your local clipboard through OSC 52.
- **Snacks:** file picker, grep, buffers, recent files, help, file explorer, bigfile protection.
  The picker, grep and explorer show dotfiles such as `.env` and `.gitignore` (but never `.git`).
- **Navigation:** smart-splits.nvim, paired with the tmux bindings above.
- **Mermaid:** `Space mm` inside a mermaid block renders it to a PNG (needs `mmdc`) and opens it in Preview.
- **Images and PDFs:** pressing Enter on one in the explorer or a picker opens it in macOS Preview, because inline kitty graphics are unreliable under tmux + WezTerm, so Snacks' inline images are turned off.
  `T` on a PDF in the explorer (or `Space pt` in a PDF buffer) opens the whole document as searchable text (needs `poppler`).
- **Merge conflicts:** git-conflict.nvim highlights conflict blocks and lets you pick a side with one key.
- **Copilot:** inline suggestions as you type.
- **LSP:** Mason installs and enables `pyright`, `clangd` and `lua_ls` automatically.
  `lazydev` makes `lua_ls` understand the `vim` global.
- **Completion:** blink.cmp, fed by LSP, paths and buffer words.
- **Treesitter:** accurate highlighting for python, c, cpp, lua, bash, json, yaml, sql, markdown, javascript and typescript.
- **Formatting:** conform.nvim on save: `ruff_format` (Python), `clang-format` (C/C++), `stylua` (Lua), LSP fallback otherwise.
- **Markdown:** render-markdown.nvim for pretty in-buffer headings, code blocks and bullets, plus a browser preview.

To add a language server, add its name to `ensure_installed` in `lua/plugins/lsp.lua`.
To add a Treesitter parser, add it to the `install` list in the same file.

## Keybinding cheat sheet

Leader is `Space`.

### tmux (prefix is `C-s`)

| Keys | Action |
| --- | --- |
| `prefix \|` or `prefix ;` | Split side by side, in the current directory |
| `prefix -` or `prefix '` | Split top and bottom, in the current directory |
| `Alt-h/j/k/l` | Move between panes and Neovim splits (no prefix) |
| `Alt-H/J/K/L` | Resize panes and Neovim splits (no prefix) |
| `Alt-,` / `Alt-.` | Previous / next window |
| `Alt-w` | Kill the current pane |
| `Alt-o` | Toggle the outer tmux off and on (for nested tmux) |
| `prefix r` | Reload the config |
| `prefix [` | Enter copy mode (vi keys) |

### Neovim

| Keys | Action |
| --- | --- |
| `C-f` | Find files |
| `Space s` | Grep the codebase |
| `Space fb` / `fr` / `fh` | Buffers / recent files / help |
| `Space e` | File explorer |
| `Alt-h/j/k/l` | Move between splits, and into tmux panes at the edge |
| `Alt-H/J/K/L` | Resize splits |
| `Enter` on an image or PDF | Open it in macOS Preview |
| `T` in the explorer, or `Space pt` | Open a PDF as searchable text |
| `Space gco` / `gct` / `gcb` / `gc0` | Merge conflict: choose ours / theirs / both / none |
| `]x` / `[x` | Next / previous merge conflict |
| `Space gcl` | List conflicts in the quickfix list |
| `gd` | Go to definition (when an LSP is attached) |
| `K` | Hover docs |
| `grn` or `Space r` | Rename symbol |
| `grr` | Find references |
| `gra` | Code action |
| `gri` | Go to implementation |
| `Space d` | Show the error under the cursor |
| `Tab` | Accept the Copilot suggestion |
| `M-Right` / `M-Down` | Accept a Copilot word / line |
| `M-]` / `M-[` | Next / previous Copilot suggestion |
| `C-]` | Dismiss Copilot |
| `C-y`, `C-n`, `C-p` | Accept / next / previous completion item |
| `Space mt` | Toggle markdown rendering |
| `Space mp` | Toggle the markdown browser preview |
| `Space mm` | Render the mermaid block under the cursor in Preview |

### WezTerm

| Keys | Action |
| --- | --- |
| `Cmd-a` | Select the entire scrollback |

## Workflow

How I use it day to day:

1. Open WezTerm and attach to or start a tmux session, one session per project (`tmux new -s name`, `tmux a -t name`).
2. Use one window per concern, for example editor, dev server, and an agent or shell.
3. Split panes with `prefix |` and `prefix -`.
   New panes start in the current directory.
4. Move around with `Alt-hjkl`, which crosses Neovim splits and tmux panes alike, and `Alt-,` / `Alt-.` for windows.
5. In Neovim, jump with `C-f` for files and `Space s` for text.
   Let LSP handle navigation with `gd` and `grr`, and let Copilot and blink.cmp handle typing.
6. Formatting happens on save, so there is no format step to remember.
7. When I SSH somewhere, I run tmux on the remote host too.
   `Alt-o` turns off my local tmux so keys go to the remote one, and OSC 52 keeps copy and paste working back to my local clipboard.
8. Close a pane with `Alt-w` and detach with `prefix d`.
   Sessions keep running, so I can reattach later.

## Merge conflicts

Because Stow symlinks into this repo, a conflict is a normal git conflict in `~/dotfiles`.
Resolve it there and the live config updates immediately.

1. Run `git pull` (or `git merge`) in `~/dotfiles`, and note the conflicted files from `git status`.
2. Open each file in Neovim.
   git-conflict.nvim highlights the blocks.
3. Put the cursor in a block and press `Space gco` (ours), `gct` (theirs), `gcb` (both) or `gc0` (none).
   Jump between blocks with `]x` and `[x`.
4. Run `git add <file>` for each resolved file, then `git commit`.

Use the zdiff3 conflict style so each block also shows the common ancestor:

```bash
git config --global merge.conflictstyle zdiff3
```

If you get stuck, `git merge --abort` returns to where you started.

## Machine-local overrides

Anything that should differ per machine goes in an untracked file instead of the repo.

- **tmux:** `~/.tmux.local.conf` is sourced last, and silently ignored if it is missing.
  Use it for clipboard commands, host-specific colors and so on.
- **WezTerm:** keep a per-machine tweak at the bottom of `.wezterm.lua` guarded by `wezterm.target_triple`.
- **Neovim:** if something must not be shared, add a gitignored file and `pcall(require, "local")` it from `init.lua`.

## Day-to-day use

Because the files are symlinked, editing config through the normal paths edits the repo:

```bash
nvim ~/.tmux.conf     # same file as ~/dotfiles/tmux/.tmux.conf
cd ~/dotfiles
git add -A && git commit -m "tmux: ..." && git push
```

Pull changes on another machine with `git pull`.
No re-stowing is needed, the symlinks already point at the files.
Reload tmux with `prefix r`, and restart Neovim or run `:source %` for Lua changes.

Commit `lazy-lock.json` whenever plugins are updated (`:Lazy update`), so every machine stays on identical plugin versions.
Run `:Lazy restore` on another machine to match the lockfile.

### Adding a new package

Mirror the path the file has relative to `$HOME`, then stow it:

```bash
mkdir -p ~/dotfiles/zsh
mv ~/.zshrc ~/dotfiles/zsh/
stow -t ~ zsh
```

For something under `~/.config`, the package needs the `.config` level inside it, e.g. `~/dotfiles/starship/.config/starship.toml`.

### Removing links

```bash
cd ~/dotfiles
stow -D -t ~ tmux wezterm nvim
```

This deletes the symlinks only.
The real files stay in the repo.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| Boxes or `?` instead of icons | Install the Nerd Fonts and restart WezTerm |
| `Alt-hjkl` does nothing in tmux | Make sure your terminal sends Alt as Escape, WezTerm does via `send_composed_key_when_left_alt_is_pressed = false` |
| Neovim errors about `vim.lsp.config` or similar | Neovim is older than 0.11, upgrade it |
| Treesitter parsers fail to build | Install a C compiler (`build-essential`, or Xcode tools on macOS) |
| Markdown preview never opens | Make sure `node` is installed, then `:Lazy build markdown-preview.nvim` |
| Copy in tmux does nothing on Linux | Add the `xclip` or `wl-copy` override from the Linux section |
| Mason install fails | Run `:checkhealth mason` and check `git`, `curl`, `unzip` are present |
| Stow conflict | See [If Stow reports a conflict](#if-stow-reports-a-conflict) |
