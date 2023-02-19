return {
  "nanozuki/tabby.nvim",
  event = "VeryLazy",
  config = function()
    require("tabby").setup()
    local filename = require "tabby.filename"
    local util = require "tabby.util"

    local hl_tabline_fill = util.extract_nvim_hl "TabLineFill"
    local hl_tab_active = { fg = "#15161e", bg = "#7aa2f7" }
    local hl_tab_inactive = { fg = "#c0caf5", bg = "#3d59a1" }
    local hl_win_active = util.extract_nvim_hl "BufferCurrent"
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
              .. " [" .. #vim.api.nvim_tabpage_list_wins(tabid) .. "] ",
            hl = { fg = hl_tab_active.fg, bg = hl_tab_active.bg, style = "bold" },
          }
        end,
        left_sep = { " ", hl = { fg = hl_tabline_fill.bg, bg = hl_tab_active.bg } },
        right_sep = { " ", hl = { fg = hl_tabline_fill.bg, bg = hl_tab_active.bg } },
      },
      inactive_tab = {
        label = function(tabid)
          return {
            " "
              .. vim.api.nvim_tabpage_get_number(tabid)
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
