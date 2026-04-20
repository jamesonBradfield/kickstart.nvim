# Neovim & Aider Setup Summary (2026)

## 1. Core Architecture
- **Modular Config**: Transitioned from a single `lua/plugins.lua` to a modular directory structure under `lua/plugins/*.lua` (core, ui, lsp, etc.).
- **Smart Navigation**: Custom `smart_nav` logic in `lua/keys.lua` handles seamless `<C-h/j/k/l>` movement between regular splits, terminal buffers, and floating windows (like `mini.files`).

## 2. AI & Aider Integration
- **Persistent Terminal**: Managed via `lua/aider.lua` using `snacks.terminal`. 
- **Centralized Config**: Aider settings are managed in `~/.aider.conf.yml`:
  - **Model**: `openrouter/qwen/qwen3.6-plus-preview:free`
  - **Architect Mode**: (Currently commented out) Prepared for `gemini/gemini-1.5-pro`.
  - **Context**: 32k token limit for chat history.
- **Keybindings (`<leader>t`)**:
  - `ta`: Toggle Aider Agent.
  - `t+`: Add current file to Aider session.

## 3. Keybinding Groups (2026 Standard)
Reorganized under logical `which-key` groups for maximum discoverability:
- **`[c]ode/symbols`**: LSP actions (rename, code actions), Symbols (Trouble).
- **`[d]ebug`**: DAP management, UI toggle, Godot launch.
- **`[e]rrors/trouble`**: Diagnostics, Quickfix, Location list.
- **`[g]it`**: Neogit, Gitsigns previews/staging.
- **`[h]arpoon/grapple`**: File tagging and indexed jumping (`h1`-`h4`).
- **`[q]sessions/quit`**: Session restoration and global exit.
- **`[s]search/pickers`**: Snacks pickers (files, grep, word, buffers).
- **`[t]erminals/aider`**: Aider, standard terminals, terminal picker, Bacon builder.
- **`[u]tils`**: Notifications, Zen mode.

## 4. LSP & Completion Stack
- **Modern Completion**: `blink.cmp` configured for **VSCode-style workflow**:
  - `Tab`: First press autofills ghost text, subsequent presses cycle list.
  - `Enter`/`Space`: Accept selection.
  - Rounded borders on all menus/docs.
- **Native 0.11 LSP**: Uses the latest `vim.lsp.config` and `vim.lsp.enable` APIs.
- **Type Support**: `lazydev` configured with `snacks.nvim` and `wezterm-types` for full autocompletion in config files.
- **UI Focus**: Virtual text and auto-hover diagnostics disabled to reduce clutter; error management centralized in `Trouble`.

## 5. Godot & Rust (gdext) Workflow
- **Rustaceanvim**: Optimized for GDExtension with `procMacro` support and `target` directory exclusion.
- **Auto-DAP**: Intelligent helper in `lua/plugins/debugging.lua` that automatically finds the Godot executable for debugging.
- **Integrated Explorer**: `mini.files` enhanced with local buffer mappings for adding files to Aider (`t+`) and toggling Grapple tags (`ha`).

---
*Created on Friday, April 3, 2026*
