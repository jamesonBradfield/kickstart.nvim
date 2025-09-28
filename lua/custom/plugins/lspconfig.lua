-- LSP Configuration for Godot and C# development
local lspconfig = require 'lspconfig'

-- OmniSharp-extended setup for better goto functionality (optional)
local omnisharp_extended_available, omnisharp_extended = pcall(require, 'omnisharp_extended')

-- Check if blink-cmp is available for enhanced capabilities
local blink_cmp_available, blink_cmp = pcall(require, 'blink.cmp')
local capabilities = vim.lsp.protocol.make_client_capabilities()
if blink_cmp_available then
  capabilities = blink_cmp.get_lsp_capabilities(capabilities)
end

-- Godot server setup function
local function setup_godot_server()
  local pipepath

  if vim.fn.has 'win32' == 1 then
    pipepath = '\\\\.\\pipe\\godot-nvim'
  else
    pipepath = vim.fn.stdpath 'cache' .. '/godot.pipe'
  end

  local success, server_name = pcall(vim.fn.serverstart, pipepath)
  if success then
    vim.g.godot_server_pipe = server_name
  else
    local fallback_server = vim.fn.serverstart()
    if fallback_server then
      vim.g.godot_server_pipe = fallback_server
      print('Godot server started on: ' .. fallback_server)
    end
  end
end

-- Common LSP keybindings
local function setup_lsp_keymaps(bufnr)
  local opts = { buffer = bufnr, silent = true }

  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>f', function()
    vim.lsp.buf.format { async = true }
  end, opts)
end

-- OmniSharp-specific keybindings
local function setup_omnisharp_keymaps(bufnr)
  local opts = { buffer = bufnr, silent = true }

  -- Use omnisharp-extended for better goto functionality if available
  if omnisharp_extended_available then
    vim.keymap.set('n', 'gd', omnisharp_extended.lsp_definition, opts)
    vim.keymap.set('n', 'gr', omnisharp_extended.lsp_references, opts)
    vim.keymap.set('n', 'gi', omnisharp_extended.lsp_implementation, opts)
    vim.keymap.set('n', '<leader>D', omnisharp_extended.lsp_type_definition, opts)
  else
    -- Fallback to standard LSP functions
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
  end
end

-- Godot LSP configuration
lspconfig.gdscript.setup {
  name = 'godot',
  cmd = { 'nc', 'localhost', '6005' },
  filetypes = { 'gdscript' },
  root_dir = lspconfig.util.root_pattern 'project.godot',
  on_attach = function(client, bufnr)
    setup_lsp_keymaps(bufnr)
  end,
}

-- OmniSharp LSP configuration
lspconfig.omnisharp.setup {
  cmd = { 'omnisharp', '--languageserver', '--hostPID', tostring(vim.fn.getpid()) },
  filetypes = { 'cs' },
  root_dir = lspconfig.util.root_pattern('*.sln', '*.csproj', 'omnisharp.json', 'function.json'),
  init_options = {},
  settings = {
    FormattingOptions = {
      EnableEditorConfigSupport = true,
      OrganizeImports = true,
      UseTabs = true,
      TabSize = 4,
      IndentSize = 4,
    },
    MsBuild = {
      LoadProjectsOnDemand = false,
    },
    RoslynExtensionsOptions = {
      EnableAnalyzersSupport = false, -- Disable all analyzers to avoid Godot conflicts
      EnableImportCompletion = true,
      AnalyzeOpenDocumentsOnly = false,
    },
    Sdk = {
      IncludePrereleases = true,
    },
  },
  on_attach = function(client, bufnr)
    -- Disable LSP formatting to avoid conflicts with Godot's tab preference
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false

    setup_lsp_keymaps(bufnr)
    setup_omnisharp_keymaps(bufnr)

    -- Enable completion triggered by <c-x><c-o>
    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
  end,
  capabilities = capabilities,
}

-- File type specific autocmds
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'gdscript',
  callback = function()
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.expandtab = false

    local opts = { buffer = true, silent = true }
    vim.keymap.set('n', '<F5>', '<cmd>!godot --path . %<CR>', opts)
    vim.keymap.set('n', '<F6>', '<cmd>!godot --path .<CR>', opts)
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'cs',
  callback = function()
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.expandtab = false -- Use tabs for Godot C#

    local opts = { buffer = true, silent = true }
    -- Build current project
    -- vim.keymap.set('n', '<F5>', '<cmd>!dotnet build<CR>', opts)
    -- -- Run current project
    -- vim.keymap.set('n', '<F6>', '<cmd>!dotnet run<CR>', opts)
    -- -- Test current project
    -- vim.keymap.set('n', '<F7>', '<cmd>!dotnet test<CR>', opts)
    -- Remove unnecessary usings
    vim.keymap.set('n', '<leader>ru', function()
      vim.lsp.buf.code_action {
        filter = function(action)
          return action.title:match 'Remove unnecessary usings' or action.title:match 'RemoveUnnecessaryImportsFixable'
        end,
        apply = true,
      }
    end, opts)
  end,
})

-- Initialize Godot server
setup_godot_server()

return {}
