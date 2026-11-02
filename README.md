# Emacs configuration for Clojure and Elixir

This configuration is kept in sync with [k13gomez/nvim-config](https://github.com/k13gomez/nvim-config) through quantum entanglement.

Vim keys come from evil, with `,` as the leader. The theme is tokyo-night (night style by default) with doom-modeline. Press `,fs` to switch the style; the choice is kept across restarts.
Elixir and HEEx files format on save through `mix format`. Terraform files format on save through `terraform fmt`.
The config is built for Emacs in a terminal (`emacs -nw`).

## Install dependencies

```bash
$ brew install emacs fd ripgrep tree-sitter-cli rust stylua clojure-lsp/brew/clojure-lsp-native elixir-ls lua-language-server
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

The first start installs the packages, compiles the vterm module (this is what needs `cmake` and `libtool`) and downloads the parinfer-rust library. A tree-sitter grammar installs the first time a file needs it. After that, run `M-x copilot-install-server` and `M-x copilot-login` once.

## Useful links

- [CIDER docs](https://docs.cider.mx)
- [evil docs](https://evil.readthedocs.io)

---

# Keybindings

`<leader>` = `,` &nbsp;·&nbsp; `<localleader>` = `,` (same key)

The leader works in normal, visual and motion state, and in the file tree. Press a prefix and wait ~300ms for the which-key popup.
To run any command by name, press `M-x` (Option+x) or `,:`.

## General

| Key | Mode | Action |
|---|---|---|
| `,:` | n, v | Search and run commands (`M-x`) |
| `,h` | n, v | Start screen |
| `,ne` | n, v | Empty buffer in new tab |
| `,nt` | n, v | Terminal in new tab |
| `,bw` / `,bW` | n, v | Write buffer / write all buffers |
| `,bq` / `,bQ` | n, v | Quit buffer / quit all |
| `,bx` | n, v | Write all and quit |
| `,bX` | n, v | Quit all, discarding changes |
| `,qq` | n, v | Quit |
| `,qa` | n, v | Quit all |
| `,qw` | n, v | Write and quit |
| `,qs` | n, v | Write all and quit all |
| `,rt` | n, v | Retab (tabs to spaces) |
| `,tl` | n, v | Toggle line numbers |
| `,ti` | n, v | Toggle parinfer in every Lisp buffer |
| `C-l` | n | Clear search highlight and redraw |

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

The signs show in the margin. Use `M-x magit` for the full git interface.

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
| `,ff` | Find files in the project |
| `,fg` | Grep the project (ripgrep) |
| `,fb` | Buffers |
| `,fh` | Help for a symbol |
| `,fs` | Switch the tokyo-night style, with live preview (remembered across restarts) |
| `C-t` / `M-t` | In any picker: open the selection in a new tab |

## File tree (treemacs)

The tree opens on the right. Its root follows the current buffer's project, and it hides dotfiles and gitignored files.

| Key | Action |
|---|---|
| `,tt` | Toggle the file tree |
| `\` | Reveal the current file in the tree |
| `t` | In the tree: open the file in a new tab |
| `H` | In the tree: show / hide dotfiles |

## Tabs

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

After `,>>` or `,<<`, Emacs waits up to 1 second for another `>` or `<` before it resizes.

## Terminal (vterm)

A terminal opens at the project root. Moving to a running terminal puts you in insert state. When the shell exits cleanly, its window and tab close. A failed exit leaves the buffer open so you can read it; press `q` to close it.

| Key | Mode | Action |
|---|---|---|
| `,Tt` | n | Terminal in new tab |
| `,Tv` | n | Terminal in vertical split |
| `,Ts` | n | Terminal in horizontal split |
| `,Tr` | n | Rename terminal (empty = automatic) |
| `C-w` | i | Window commands from the terminal |
| `C-v` `Esc` | i | Send `Esc` to the shell |

## Case conversion

The `cs` keys work in normal and visual state. The `,k` keys do the same thing from the leader.

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
| `(` | n, v, o | Clojure and Elisp: move to the open bracket of the enclosing list |
| `)` | n, v, o | Clojure and Elisp: move to the close bracket of the enclosing list |

Brackets inside strings and comments don't count for `(` and `)`. Parinfer does the structural editing.

## Clojure (CIDER / Portal)

These keys are local to Clojure buffers.

Connection and sessions:

| Key | Action |
|---|---|
| `,repl` / `,cf` | Connect to a REPL (asks for host and port) |
| `,cd` / `,sq` | Disconnect |
| `,sl` | List sessions |
| `,ss` | Link this buffer to a session |

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

REPL, navigation and macros:

| Key | Action |
|---|---|
| `,ls` / `,lv` / `,ll` | Show the REPL buffer |
| `,lr` | Clear REPL output |
| `,gd` | Goto definition |
| `,x1` / `,xa` | Macroexpand once / fully |

Tests and reloading:

| Key | Action |
|---|---|
| `,tc` / `,tn` / `,ta` | CIDER: run test at point / ns tests / all project tests |
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
| `,mt` | n | mix: test at point |
| `,mf` | n | mix: test current file |
| `,ma` | n | mix: test all |
| `,mr` | n | mix: re-run failed tests |
| `,mc` | n | mix: compile |
| `,md` | n | mix: `deps.get` |

## LSP (eglot)

eglot starts in Clojure, Elixir, HEEx and Lua buffers. All keys except `,df` exist only there.

| Key | Mode | Action |
|---|---|---|
| `gd` | n | Goto definition |
| `K` | n | Documentation |
| `,df` | n, v | Format buffer |
| `,dd` | n, v | Goto declaration |
| `,dt` | n, v | Goto type definition |
| `,ds` | n, v | Signature help |
| `,dn` | n, v | Rename symbol |
| `,de` | n, v | Show diagnostic at cursor |
| `,dq` | n, v | Buffer diagnostics |
| `,dj` / `,dk` | n, v | Next / previous diagnostic |
| `,da` | n, v | Code action |
| `,dw` | n, v | Workspace diagnostics |
| `,dr` | n, v | References |
| `,di` | n, v | Implementations |

## Completion (corfu, insert state)

The popup opens on its own after one character.

| Key | Action |
|---|---|
| `C-SPC` | Trigger completion |
| `C-b` / `C-f` | Scroll docs up / down |
| `C-e` | Abort |
| `RET` | Confirm the selected item, or insert a newline if none is selected |

## Copilot

Copilot runs in programming buffers.

| Key | Action |
|---|---|
| `M-\` | Request a suggestion |
| `TAB` | Accept the suggestion |
| `M-]` / `M-[` | Next / previous suggestion |
| `M-<right>` | Accept the next word |
| `C-M-<right>` | Accept the next line |
| `C-]` | Dismiss the suggestion |

## Folding

Programming buffers fold by code block (hideshow). Folds start open.

| Key | Action |
|---|---|
| `za` | Toggle fold under cursor |
| `zo` / `zc` | Open / close fold under cursor |
| `zR` / `zM` | Open / close *all* folds |

## Start screen

The start screen lists recent files and projects. `,h` opens it again.

| Key | Action |
|---|---|
| `e` | New empty buffer |
| `q` | Back to the previous buffer, or close the window, tab or Emacs if there is none |
