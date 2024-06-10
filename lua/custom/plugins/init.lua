-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'quarto-dev/quarto-nvim',
    dev = false,
    dependencies = {
      { 'hrsh7th/nvim-cmp' },
      {
        'jmbuhr/otter.nvim',
        config = function()
          require 'otter'.setup {
            lsp = {
              hover = {
                border = require 'misc.style'.border
              }
            }
          }
        end,
      },

    },
    config = function()
      require 'quarto'.setup {
        debug = false,
        closePreviewOnExit = true,
        lspFeatures = {
          enabled = true,
          languages = { 'r', 'python', 'julia', 'bash', 'lua' },
          chunks = 'all', -- 'curly' or 'all'
          diagnostics = {
            enabled = true,
            triggers = { "BufWritePost" }
          },
          completion = {
            enabled = true,
          },
        },
        keymap = {
          hover = 'K',
          definition = 'gd'
        },
      }
    end
  },

  {"sindrets/diffview.nvim"},
  -- completion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-nvim-lsp-signature-help' },
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-path' },
      { 'hrsh7th/cmp-calc' },
      { 'hrsh7th/cmp-emoji' },
      { 'saadparwaiz1/cmp_luasnip' },
      { 'f3fora/cmp-spell' },
      { 'ray-x/cmp-treesitter' },
      { 'kdheepak/cmp-latex-symbols' },
      { 'jmbuhr/cmp-pandoc-references' },
      { 'L3MON4D3/LuaSnip' },
      { 'rafamadriz/friendly-snippets' },
      { 'onsails/lspkind-nvim' },
      {
              "zbirenbaum/copilot.lua",
              config = function()
                require("copilot").setup({
                  suggestion = {
                    enabled = true,
                    auto_trigger = true,
                    debounce = 75,
                    keymap = {
                      accept = "<C-e>",
                      accept_word = false,
                      accept_line = false,
                      next = "<D-]>",
                      prev = "<D-[>",
                      dismiss = "<D-]>",
                    },
                  },
                  panel = { enabled = false },
                })
              end,
            },
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      local lspkind = require "lspkind"
      lspkind.init()


      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = {
          ['<C-f>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ['<C-n>'] = cmp.mapping(function(fallback)
            if luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
              fallback()
            end
          end, { "i", "s" }),
          ['<C-p>'] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ['<c-a>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({
            select = true,
          }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i", "s" }),
        },
        experimental = {
          ghost_text = false
        },
        autocomplete = false,
        formatting = {
          format = lspkind.cmp_format {
            with_text = true,
            menu = {
              otter = "[🦦]",
              copilot = '[]',
              luasnip = "[snip]",
              nvim_lsp = "[LSP]",
              buffer = "[buf]",
              path = "[path]",
              spell = "[spell]",
              pandoc_references = "[ref]",
              tags = "[tag]",
              treesitter = "[TS]",
              calc = "[calc]",
              latex_symbols = "[tex]",
              emoji = "[emoji]",
            },
          },
        },
        sources = {
          { name = 'copilot',                keyword_length = 3, max_item_count = 3 },
          { name = 'otter' }, -- for code chunks in quarto
          { name = 'path' },
          { name = 'nvim_lsp' },
          { name = 'nvim_lsp_signature_help' },
          { name = 'luasnip',                keyword_length = 3, max_item_count = 3 },
          { name = 'pandoc_references' },
          { name = 'buffer',                 keyword_length = 5, max_item_count = 3 },
          { name = 'spell' },
          { name = 'treesitter',             keyword_length = 5, max_item_count = 3 },
          { name = 'calc' },
          { name = 'latex_symbols' },
          { name = 'emoji' },
        },
        view = {
          entries = "native",
        },
        window = {
          documentation = {
            border = require 'misc.style'.border,
          },
        },
      })
      -- for friendly snippets
      require("luasnip.loaders.from_vscode").lazy_load()
      -- for custom snippets
      require("luasnip.loaders.from_vscode").lazy_load({ paths = { "~/.config/nvim/snips" } })
    end
  },


  -- send code from python/r/qmd documets to a terminal or REPL
  -- like ipython, R, bash
  {
    'jpalardy/vim-slime',
    init = function()
      Quarto_is_in_python_chunk = function()
        require 'otter.tools.functions'.is_otter_language_context('python')
      end

      vim.cmd [[
      function SlimeOverride_EscapeText_quarto(text)
      call v:lua.Quarto_is_in_python_chunk()
      if exists('g:slime_python_ipython') && len(split(a:text,"\n")) > 1 && b:quarto_is_python_chunk
      return ["%cpaste -q", "\n", g:slime_dispatch_ipython_pause, a:text, "--", "\n"]
      else
      return a:text
      end
      endfunction
      ]]

      local function mark_terminal()
        vim.g.slime_last_channel = vim.b.terminal_job_id
        vim.print(vim.g.slime_last_channel)
      end

      local function set_terminal()
        vim.b.slime_config = { jobid = vim.g.slime_last_channel }
      end

      vim.b.slime_cell_delimiter = "#%%"

      -- slime, neovvim terminal
      vim.g.slime_target = "neovim"
      vim.g.slime_python_ipython = 1

      -- -- slime, tmux
      -- vim.g.slime_target = 'tmux'
      -- vim.g.slime_bracketed_paste = 1
      -- vim.g.slime_default_config = { socket_name = "default", target_pane = ".1" }

      local function toggle_slime_tmux_nvim()
        if vim.g.slime_target == 'tmux' then
          pcall(function()
            vim.b.slime_config = nil
            vim.g.slime_default_config = nil
          end
          )
          -- slime, neovvim terminal
          vim.g.slime_target = "neovim"
          vim.g.slime_bracketed_paste = 0
          vim.g.slime_python_ipython = 1
        elseif vim.g.slime_target == 'neovim' then
          pcall(function()
            vim.b.slime_config = nil
            vim.g.slime_default_config = nil
          end
          )
          -- -- slime, tmux
          vim.g.slime_target = 'tmux'
          vim.g.slime_bracketed_paste = 1
          vim.g.slime_default_config = { socket_name = "default", target_pane = ".2" }
        end
      end

      require 'which-key'.register({
        ['<leader>cm'] = { mark_terminal, 'mark terminal' },
        ['<leader>cs'] = { set_terminal, 'set terminal' },
        ['<leader>ct'] = { toggle_slime_tmux_nvim, 'toggle tmux/nvim terminal' },
      })
    end
  },

  -- paste an image to markdown from the clipboard
  -- :PasteImg,
  { 'ekickx/clipboard-image.nvim' },

}
