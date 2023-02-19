return {
  "nanozuki/tabby.nvim",
  event = "VeryLazy",
  config = function()
    require("tabby").setup()
    local filename = require "tabby.filename"
    local util = require "tabby.util"

    local hl_tabline_fill = util.extract_nvim_hl "TabLineFill"
    local hl_tab_active = { fg = "#c0caf5", bg = "#3d59a1" }
    local hl_tab_inactive = { fg = "#8a8fb0", bg = "#273967" }
    local hl_win_active = { fg = "#c0caf5", bg = "#3b4261" }
    local hl_win_inactive = { fg = "#737aa2", bg = "#292e42" }

    local get_parent = function()
      local parent = vim.fn.fnamemodify(vim.fn.getcwd(), ":h")
      if parent ~= "" and parent ~= "/" then
        local grand_parent = vim.fn.fnamemodify(vim.fn.fnamemodify(parent, ":h"), ":t")
        if grand_parent ~= "" then
          return "../" .. vim.fn.fnamemodify(parent, ":t")
        else
          print(parent)
          return "/" .. vim.fn.fnamemodify(parent, ":t")
        end
      else
        return ""
      end
    end

    local count_windows = function()
      local wc = 0
      local windows = vim.api.nvim_tabpage_list_wins(0)

      for _, v in pairs(windows) do
        local cfg = vim.api.nvim_win_get_config(v)
        local ft = vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(v), "filetype")

        if (cfg.relative == "" or cfg.external == true) and ft ~= "qf" then
          wc = wc + 1
        end
      end
      return wc
    end

    local tabline = {
      hl = "TabLineFill",
      layout = "active_tab_with_wins",
      active_tab = {
        label = function(tabid)
          return {
            -- stylua: ignore
            " "
              .. vim.api.nvim_tabpage_get_number(tabid)
              .. " " .. get_parent()
              .. "/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
              .. " [" .. count_windows() .. "] ",
            hl = { fg = hl_tab_active.fg, bg = hl_tab_active.bg, style = "bold" },
          }
        end,
        left_sep = { " ", hl = { fg = hl_tabline_fill.bg, bg = hl_tab_active.bg } },
        right_sep = { " ", hl = { fg = hl_tabline_fill.bg, bg = hl_tab_active.bg } },
      },
      inactive_tab = {
        label = function(tabid)
          return {
            -- stylua: ignore
            " "
              .. vim.api.nvim_tabpage_get_number(tabid)
              .. " " .. filename.unique(vim.api.nvim_tabpage_get_win(tabid))
              .. " ["
              .. #vim.api.nvim_tabpage_list_wins(tabid)
              .. "] ",
            hl = { fg = hl_tab_inactive.fg, bg = hl_tab_inactive.bg, style = "bold" },
          }
        end,
        left_sep = { " ", hl = { fg = hl_tabline_fill.bg, bg = hl_tab_inactive.bg } },
        right_sep = { " ", hl = { fg = hl_tabline_fill.bg, bg = hl_tab_inactive.bg } },
      },
      top_win = {
        label = function(winid)
          return {
            " "
              .. vim.api.nvim_win_get_buf(winid)
              .. ": "
              .. filename.unique(winid)
              .. " "
              .. (
                vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(winid), "modified")
                  -- and "[●]"
                  and "[+]"
                or ""
              ),
            hl = { fg = hl_win_active.fg, bg = hl_win_active.bg },
          }
        end,
        left_sep = { " ", hl = { fg = hl_tabline_fill.bg, bg = hl_win_active.bg } },
        right_sep = { " ", hl = { fg = hl_tabline_fill.bg, bg = hl_win_active.bg } },
      },
      win = {
        label = function(winid)
          return {
            " "
              .. vim.api.nvim_win_get_buf(winid)
              .. ": "
              .. filename.unique(winid)
              .. " "
              .. (
                vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(winid), "modified")
                  and "[+]"
                or ""
              ),
            hl = { fg = hl_win_inactive.fg, bg = hl_win_inactive.bg },
          }
        end,
        left_sep = { " ", hl = { fg = hl_tabline_fill.bg, bg = hl_win_inactive.bg } },
        right_sep = { " ", hl = { fg = hl_tabline_fill.bg, bg = hl_win_inactive.bg } },
      },
    }

    require("tabby").setup {
      tabline = tabline,
    }
  end,
}
