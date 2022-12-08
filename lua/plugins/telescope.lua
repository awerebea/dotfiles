-- import telescope plugin safely
local telescope_setup, telescope = pcall(require, "telescope")
if not telescope_setup then
  return
end

-- import telescope actions safely
local actions_setup, actions = pcall(require, "telescope.actions")
if not actions_setup then
  return
end

-- configure telescope
telescope.setup({
  -- configure custom mappings
  defaults = {
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = {
        preview_cutoff = 110,
        preview_width = { 0.5, min = 70, max = 100 },
        width = 0.999,
        height = 0.999,
      },
      vertical = {
        preview_cutoff = 25,
        preview_height = { 0.6, min = 20, max = 40 },
        width = 0.999,
        height = 0.999,
      },
    },
    mappings = {
      i = {
        ["<C-k>"] = actions.move_selection_previous, -- move to prev result
        ["<C-j>"] = actions.move_selection_next, -- move to next result
        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist, -- send all to quickfixlist
        ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- send selected to quickfixlist
        ["<esc>"] = actions.close,
      },
    },
  },
  pickers = {
    buffers = {
      ignore_current_buffer = true,
      sort_mru = true,
    },
    live_grep = {
      only_sort_text = true,
    },
    git_commits = {
      layout_strategy = "vertical",
    },
    git_bcommits = {
      layout_strategy = "vertical",
    },
    git_status = {
      layout_strategy = "vertical",
    },
  },
})

telescope.load_extension("fzf")
