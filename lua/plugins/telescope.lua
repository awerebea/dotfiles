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
    layout_config = {
      horizontal = { width = 0.999, height = 0.999 },
      vertical = { width = 0.999, height = 0.999 },
    },
    mappings = {
      i = {
        ["<C-k>"] = actions.move_selection_previous, -- move to prev result
        ["<C-j>"] = actions.move_selection_next, -- move to next result
        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- send selected to quickfixlist
        ["<esc>"] = actions.close,
      },
    },
  },
  pickers = {
    buffers = {
      layout_strategy = "horizontal",
      layout_config = {
        preview_cutoff = 110,
        preview_width = { 0.5, min = 70, max = 100 },
      },
      ignore_current_buffer = true,
      sort_mru = true,
    },
    find_files = {
      layout_strategy = "horizontal",
      layout_config = {
        preview_cutoff = 110,
        preview_width = { 0.5, min = 70, max = 100 },
      },
    },
    live_grep = {
      layout_strategy = "horizontal",
      layout_config = {
        preview_cutoff = 110,
        preview_width = { 0.5, min = 70, max = 100 },
      },
      only_sort_text = true,
    },
    git_commits = {
      layout_strategy = "vertical",
      layout_config = {
        preview_cutoff = 35,
        preview_height = { 0.5, min = 30, max = 40 },
      },
    },
    git_bcommits = {
      layout_strategy = "vertical",
      layout_config = {
        preview_cutoff = 35,
        preview_height = { 0.5, min = 30, max = 40 },
      },
    },
    git_status = {
      layout_strategy = "vertical",
      layout_config = {
        preview_cutoff = 35,
        preview_height = { 0.5, min = 30, max = 40 },
      },
    },
  },
})

telescope.load_extension("fzf")
