# Emacs configuration for Clojure and Elixir

This config gives Emacs the keys and look of `~/.config/nvim`. It uses evil for Vim keys and Emacs packages for the rest. `,` is the leader. Press it and wait to see the keys.

## Install

```bash
$ brew install emacs
$ emacs -nw
```

The first start installs the packages. After that, run `M-x copilot-login` once.

## Packages

| nvim | Emacs |
|---|---|
| conjure | CIDER |
| vim-sexp | lispyville |
| parinfer-rust | parinfer-rust-mode |
| nvim-lspconfig | eglot |
| conform | apheleia |
| nvim-cmp | corfu, cape |
| telescope | vertico, consult |
| neo-tree | treemacs |
| gitsigns, fugitive | diff-hl, magit |
| lualine | doom-modeline |
| material.nvim | doom-themes (`doom-material-dark`) |
| which-key | which-key |

## Keys that differ from nvim

| nvim | Emacs |
|---|---|
| `<leader>tab` | `,to` (new tab) |
| `<leader>>>`, `<leader><<` | `,>`, `,<`. Press `>` or `<` again to repeat. |
| `<leader>,>>`, `<leader>,<<` | `,,>`, `,,<` |
| `case`, `css`, `csk`, `csc`, `csp`, `csm` | `,kr`, `,ks`, `,kk`, `,kc`, `,kp`, `,km` |
| `<leader>repl` | `,repl` asks for the port |
| `<leader>w…` | `,w(`, `,w[`, `,w{`, `,ws`, `,wv`, `,wc`, `,wr` |

## Not available

No package gives these, so the config leaves them out:
- The Portal and Clojure helpers (`,cv`, `,cp`, `,ct`, `,cT`, `,cu`, `,cg`, `,cj`, `,cw`, `,cef`, `,cro`, `,crt`, `,crn`, `,crr`).
- The other vim-sexp keys: tail wraps, element wraps, insert, put, replace and align comments.
- The empty UUID, hash and timestamp inserts, and `,rt` (retab).
- Completion of library versions in `deps.edn` (cmp-clojure-deps).
- The elixir-ls test lenses. Use `,mt` to run the test at the cursor.
