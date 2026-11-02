# Emacs configuration for Clojure and Elixir

This config gives Emacs the keys and look of `~/.config/nvim`. It uses evil for Vim keys and Emacs packages for the rest. `,` is the leader. Press it and wait to see the keys.

## Install

```bash
$ brew install emacs
$ emacs -nw
```

The first start installs the packages and compiles the vterm module, which needs `brew install cmake libtool`. After that, run `M-x copilot-login` once.

## Packages

| nvim | Emacs |
|---|---|
| conjure | CIDER |
| parinfer-rust | parinfer-rust-mode |
| nvim-lspconfig | eglot |
| conform | apheleia |
| nvim-cmp | corfu, cape |
| telescope | vertico, consult |
| neo-tree | treemacs |
| gitsigns, fugitive | diff-hl, magit |
| lualine | doom-modeline |
| tokyonight.nvim | tokyo-night (night by default; `,fs` switches the style and remembers it) |
| which-key | which-key |
| `:terminal` | vterm |

## Keys that differ from nvim

| nvim | Emacs |
|---|---|
| `<leader>repl` | `,repl` asks for the port |
| (none) | `,kr` `,ks` `,kk` `,kc` `,kp` `,km` repeat the `csr` `css` `csk` `csc` `csp` `csm` case keys |

Behaviour that differs:
- The file tree's root follows the current buffer's project. neo-tree's root stays at the cwd.
- `,>>`, `,<<` and the `,,` height keys wait up to 1 second for more `>` or `<` presses, as Vim's `timeoutlen` does.

## Not available

No package gives these, so the config leaves them out:
- Completion of library versions in `deps.edn` (cmp-clojure-deps).
- The elixir-ls test lenses. Use `,mt` to run the test at the cursor.
