return {
    'kevinhwang91/nvim-ufo',
    dependencies = {
        'kevinhwang91/promise-async',
        'neovim/nvim-lspconfig',
    },
    event = "VeryLazy",
    config = function()
        -- Create directory for storing folds
        local view_dir = vim.fn.stdpath("data") .. "/views"
        if vim.fn.isdirectory(view_dir) == 0 then
            vim.fn.mkdir(view_dir, "p")
        end
        
        -- Set view options
        vim.opt.viewdir = view_dir
        vim.opt.viewoptions:remove("options")
        
        -- Create autocommands for saving and loading folds
        local augroup = vim.api.nvim_create_augroup("SaveLoadFolds", { clear = true })
        vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
            group = augroup,
            pattern = "*.*",
            callback = function()
                vim.cmd.mkview()
            end
        })
        vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
            group = augroup,
            pattern = "*.*",
            callback = function()
                vim.cmd.loadview({ mods = { emsg_silent = true }})
            end
        })

        -- Fold options
        vim.o.foldcolumn = '1'
        vim.o.foldlevel = 99 -- Using ufo provider need a large value
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true

        -- Keymaps
        vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
        vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
        vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds)
        vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith)
        
        -- Handler for customizing fold text
        local handler = function(virtText, lnum, endLnum, width, truncate)
            local newVirtText = {}
            local suffix = ('  %d lines'):format(endLnum - lnum)
            local sufWidth = vim.fn.strdisplaywidth(suffix)
            local targetWidth = width - sufWidth
            local curWidth = 0
            for _, chunk in ipairs(virtText) do
                local chunkText = chunk[1]
                local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                if targetWidth > curWidth + chunkWidth then
                    table.insert(newVirtText, chunk)
                else
                    chunkText = truncate(chunkText, targetWidth - curWidth)
                    local hlGroup = chunk[2]
                    table.insert(newVirtText, {chunkText, hlGroup})
                    chunkWidth = vim.fn.strdisplaywidth(chunkText)
                    if curWidth + chunkWidth < targetWidth then
                        suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
                    end
                    break
                end
                curWidth = curWidth + chunkWidth
            end
            table.insert(newVirtText, {suffix, 'Comment'})
            return newVirtText
        end

        -- Add folding capabilities to LSP
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities.textDocument.foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true
        }

        -- Setup UFO
        require('ufo').setup({
            open_fold_hl_timeout = 150,
            close_fold_kinds_for_ft = {
                default = {'imports', 'comment'},
            },
            preview = {
                win_config = {
                    border = {'', '─', '', '', '', '─', '', ''},
                    winhighlight = 'Normal:Folded',
                    winblend = 0
                },
            },
            provider_selector = function(bufnr, filetype, buftype)
                return {'lsp', 'indent'}
            end,
            fold_virt_text_handler = handler
        })

        -- Apply capabilities to all LSP servers
        local lspconfig = require('lspconfig')
        local servers = vim.lsp.get_clients()
        
        for _, ls in ipairs(servers) do
            lspconfig[ls.name].setup({
                capabilities = capabilities,
            })
        end
    end
}
