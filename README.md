# Emacs configuration for Clojure and Elixir

<p align="center"><img src="emacsium.png" alt="Neovimium entangled with Emacsium" width="800"></p>

## Why two quantum entangled configs

I like Neovim, and it's where I feel at home. I've also always wanted the Clojure integration that CIDER gives Emacs. This pair of configs gets me both: my own Neovim configuration, ported into Emacs. That goes further than switching on evil mode or installing a prepackaged Doom Emacs. The Emacs side works like the Neovim setup I already know, not like someone else's take on Vim inside Emacs.

This configuration is kept in sync with [k13gomez/nvim-config](https://github.com/k13gomez/nvim-config) through quantum entanglement.

The theme is tokyo-night (night style by default) with doom-modeline. Press `,fs` to switch the style; the choice is kept across restarts.
Elixir and HEEx files format on save through `mix format`. Terraform files format on save through `terraform fmt`.
Vim keys come from evil, and the config is built for Emacs in a terminal (`emacs -nw`).
The dashboard shows `emacsium.png` in a GUI frame. In a terminal, it shows a sixel image inside tmux, if the terminal supports sixel. Other terminals show the text banner.

## Install dependencies

```bash
$ brew install ripgrep stylua clojure-lsp/brew/clojure-lsp-native elixir-ls lua-language-server
$ brew install emacs cmake libtool
```

Terraform formatting needs `terraform` on the `PATH`, and Copilot needs Node. The icons need a Nerd Font in the terminal.

## Install configuration

```bash
$ mkdir -p ~/.config
$ git clone git@github.com:k13gomez/emacs-config.git ~/.config/emacs
```

## Launch Emacs

```bash
$ emacs -nw
```

On first launch, Emacs installs the packages from GNU ELPA, NonGNU ELPA and MELPA. It compiles the vterm module, which is what needs `cmake` and `libtool`, and downloads the parinfer-rust library. A tree-sitter grammar installs the first time a file of its type opens. After that, run `M-x copilot-install-server` and `M-x copilot-login` once.

## Useful links

- [CIDER docs](https://docs.cider.mx)
- [evil docs](https://evil.readthedocs.io)

---

# Keybindings

`<leader>` = `,` &nbsp;·&nbsp; `<localleader>` = `,` (same key)

Press a prefix and the which-key popup opens at once. Leader keys also work in visual state and in the file tree.
To run any command by name, press `,:` or `M-x` (Option+x). The mouse works in the terminal, and the scroll wheel scrolls the window.

## General

| Key | Action |
|---|---|
| `,:` | Search and run commands (`M-x`) |
| `,h` | Start screen |
| `,ne` | Empty buffer in new tab |
| `,nt` | Terminal in new tab |
| `,bw` / `,bW` | Write buffer / write all buffers |
| `,bq` / `,bQ` | Quit buffer / quit all |
| `,bx` | Write all and quit all |
| `,bX` | Quit all, discarding changes |
| `,qq` | Quit |
| `,qa` | Quit all |
| `,qw` | Write and quit |
| `,qs` | Write all and quit all |
| `,rt` | Retab (tabs to spaces) |
| `,tl` | Toggle line numbers |
| `,ti` | Toggle parinfer in every buffer |
| `C-l` | Clear search highlight and redraw |

## Insert / utilities (`,u…`)

| Key | Action |
|---|---|
| `,uu` | Insert UUID |
| `,ue` | Insert empty UUID |
| `,uh` | Insert random hex hash |
| `,uts` | Insert ISO-8601 timestamp |
| `,ufx` | Pretty-print XML buffer |
| `,ufj` | Pretty-print JSON buffer |

## Packages (`,p…`)

| Key | Action |
|---|---|
| `,pu` | Upgrade all packages |
| `,pl` | List packages |
| `,pc` | Delete the packages that nothing needs any more |

## Git (diff-hl)

Signs in the margin mark changed lines. Use `M-x magit` for the full git interface.

| Key | Action |
|---|---|
| `]c` / `[c` | Next / previous hunk |
| `,Gp` | Preview hunk |
| `,Gs` / `,Gr` | Stage / reset hunk |
| `,Gb` | Blame line |
| `,Gt` | Toggle git signs |

## Files & buffers

| Key | Action |
|---|---|
| `,ff` | Find files |
| `,fg` | Grep (ripgrep) |
| `,fb` | Buffers |
| `,fh` | Help for a symbol |
| `,fs` | Switch the tokyo-night style, with live preview (remembered across restarts) |
| `C-t` / `M-t` | In a picker: open the selection in a new tab |

## File tree (treemacs)

The tree opens on the right and follows the current file. It hides dotfiles and gitignored files.

| Key | Action |
|---|---|
| `,tt` | Toggle the file tree |
| `\` | Reveal the current file in the tree |
| `Enter` | In the tree: open the file |
| `Tab` | In the tree: expand / collapse the node |
| `t` | In the tree: open the file in a new tab |
| `H` | In the tree: show / hide dotfiles |

## Tabs

The tab bar is always shown, with tab numbers. A tab is named after its buffer; a terminal's buffer takes the title the shell sets.

| Key | Action |
|---|---|
| `` ,` `` | Last tab (backtick) |
| `,1` … `,9` | Go to tab N |
| `,0` | Last tab |

## Window resize

Vertical (wider / narrower):

| Key | Δ |
|---|---|
| `,>>` / `,<<` | ±5 |
| `,>>>` / `,<<<` | ±10 |
| `,>>>>` / `,<<<<` | ±20 |

Horizontal (taller / shorter):

| Key | Δ |
|---|---|
| `,,>>` / `,,<<` | ±5 |
| `,,>>>` / `,,<<<` | ±10 |
| `,,>>>>` / `,,<<<<` | ±20 |

After `,>>` or `,<<`, Emacs waits up to 200 ms for another `>` or `<` before it resizes.

## Terminal (vterm)

Moving to a window with a running shell puts it in insert state, ready to type. When the shell exits cleanly, its buffer closes. A failed exit leaves the buffer open so you can read it; press `q` to close it.

| Key | Mode | Action |
|---|---|---|
| `,Tt` | n | Terminal in new tab |
| `,Tv` | n | Terminal in vertical split |
| `,Ts` | n | Terminal in horizontal split |
| `,Tr` | n | Rename terminal (empty = automatic) |
| `Esc` | i | Leave insert state |
| `C-w` | i | Window commands from the terminal |
| `C-v` `Esc` | i | Send `Esc` to the shell |

## Case conversion

The `cs` keys work in normal and visual state. The `,k` keys do the same from the leader.

| Key | Action |
|---|---|
| `csr` / `,kr` | Rotate case |
| `css` / `,ks` | → `snake_case` |
| `csk` / `,kk` | → `kebab-case` |
| `csc` / `,kc` | → `camelCase` |
| `csp` / `,kp` | → `PascalCase` |
| `csm` / `,km` | → `MACRO_CASE` |

## Editing

| Key | Mode | Action |
|---|---|---|
| `gc{motion}` / `gcc` | n, v | Comment or uncomment |
| `ga{motion}` / `gA{motion}` | n, v | Align left / right on a character (evil-lion) |
| `(` | n, v, o | Move to the open bracket of the enclosing list |
| `)` | n, v, o | Move to the close bracket of the enclosing list |

`(` and `)` work in Clojure and Emacs Lisp buffers. Brackets inside strings, regexes, comments and char literals don't count. Parinfer does the structural editing.

## Clojure (CIDER / Portal)

These keys are local to Clojure buffers. CIDER doesn't start a REPL on its own, so connect to a running one.

Connection and sessions:

| Key | Action |
|---|---|
| `,repl` / `,cf` | Connect to a REPL |
| `,cd` | Disconnect |
| `,sq` | Close the current session |
| `,sl` | List sessions |
| `,ss` | Select a session for this buffer |

Evaluation:

| Key | Mode | Action |
|---|---|---|
| `,ee` | n | Eval current form |
| `,er` | n | Eval root form |
| `,ew` | n | Eval word |
| `,ece` | n | Eval current form, result as a comment |
| `,ecr` | n | Eval root form, result as a comment |
| `,e!` | n | Eval current form and replace it with the result |
| `,eb` / `,ef` | n | Eval buffer / file |
| `,ei` | n | Interrupt |
| `,E` | v | Eval selection |
| `,cef` | n | Call the fn at cursor with no arguments |

REPL buffer:

| Key | Action |
|---|---|
| `,ls` / `,lv` / `,ll` | Show the REPL buffer |
| `,lr` | Clear the REPL output |

Navigation and macros:

| Key | Action |
|---|---|
| `,gd` | Goto definition |
| `,x1` / `,xa` | Macroexpand once / fully |

Tests and reloading:

| Key | Action |
|---|---|
| `,tc` / `,tn` / `,ta` | Run test at cursor / ns tests / all project tests |
| `,cro` / `,crt` | `clojure.test`: run the test at cursor / all tests in the ns |
| `,crn` | Reload current ns |
| `,rr` | Refresh changed namespaces |
| `,crr` | Reset clara rules cache |

Portal and helpers:

| Key | Action |
|---|---|
| `,cp` | Portal: add lib |
| `,ct` / `,cu` | Portal: taps on / off |
| `,cT` | `(tap> word-at-cursor)` |
| `,cg` | Portal: get selected |
| `,cv` | Find library versions for word at cursor |
| `,cj` | JVM PID |
| `,cw` | Enable `*warn-on-reflection*` |

## Elixir (inf-elixir / mix)

These keys are local to Elixir buffers.

| Key | Mode | Action |
|---|---|---|
| `,cs` | n | Start `iex -S mix` |
| `,ee` | n | Send line to iex |
| `,eb` | n | Send buffer to iex |
| `,E` | v | Send selection to iex |
| `,mt` | n | mix: test at cursor |
| `,mf` | n | mix: test current file |
| `,ma` | n | mix: test all |
| `,mr` | n | mix: re-run failed tests |
| `,mc` | n | mix: compile |
| `,md` | n | mix: `deps.get` |

The `mix` keys show their output in a compilation buffer; `q` closes it.

## LSP (eglot)

The language servers are clojure-lsp, elixir-ls and lua-language-server. All keys except `,df` exist only in buffers with a server. Diagnostics are underlined and marked by a sign, without inline text.

| Key | Mode | Action |
|---|---|---|
| `gd` | n | Goto definition |
| `K` | n | Documentation (hover) |
| `,df` | n, v | Format buffer (apheleia) |
| `,dd` | n | Goto declaration |
| `,dt` | n | Goto type definition |
| `,ds` | n | Signature help |
| `,dn` | n | Rename symbol |
| `,de` | n | Show diagnostic at cursor |
| `,dq` | n | List buffer diagnostics |
| `,dj` / `,dk` | n | Next / previous diagnostic |
| `,da` | n, v | Code action |
| `,dw` | n | Workspace diagnostics |
| `,dr` | n | References |
| `,di` | n | Implementations |

## Completion (corfu, insert state)

The popup opens as you type.

| Key | Action |
|---|---|
| `C-Space` | Trigger completion |
| `C-b` / `C-f` | Scroll docs up / down |
| `C-e` | Abort |
| `Enter` | Confirm the selected item, or insert a newline if none is selected |

## Copilot

Suggestions show as dimmed text at the cursor.

| Key | Action |
|---|---|
| `M-\` | Request a suggestion |
| `Tab` | Accept the suggestion |
| `M-]` / `M-[` | Next / previous suggestion |
| `M-Right` | Accept the next word |
| `C-M-Right` | Accept the next line |
| `C-]` | Dismiss the suggestion |

## Folding

Programming buffers fold by code block (hideshow). Folds start open.

| Key | Action |
|---|---|
| `za` | Toggle fold under cursor |
| `zo` / `zc` | Open / close fold under cursor |
| `zR` / `zM` | Open / close *all* folds |

## Start screen (dashboard)

The start screen lists recent files and projects, and shows how long startup took. `,h` opens it again.

The terminal image comes from `sixels/<theme>.sixel`, for example `sixels/tokyo-night-storm.sixel`. A theme without a file gets one rendered with ImageMagick on the first start, and later starts use it again. After a change to `emacsium.png`, delete the files in `sixels/` to render them again. A file is also rendered again when the terminal's cell size changes.

| Key | Action |
|---|---|
| `e` | New empty buffer |
| `q` | Leave the start screen (back to the previous buffer, or close the window, tab or Emacs) |
