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

local trouble = require("trouble.providers.telescope")
local path_actions = require("telescope_insert_path")

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
        ["<C-M-j>"] = actions.cycle_history_next,
        ["<C-M-k>"] = actions.cycle_history_prev,
        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist, -- send all to quickfixlist
        ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- send selected to quickfixlist
        ["<Esc><Esc>"] = actions.close,
        ["<c-t>"] = trouble.open_with_trouble,
      },
      n = {
        ["<c-t>"] = trouble.open_with_trouble,
        ["[i"] = path_actions.insert_relpath_i_visual,
        ["[I"] = path_actions.insert_relpath_I_visual,
        ["[a"] = path_actions.insert_relpath_a_visual,
        ["[A"] = path_actions.insert_relpath_A_visual,
        ["[o"] = path_actions.insert_relpath_o_visual,
        ["[O"] = path_actions.insert_relpath_O_visual,
        ["]i"] = path_actions.insert_abspath_i_visual,
        ["]I"] = path_actions.insert_abspath_I_visual,
        ["]a"] = path_actions.insert_abspath_a_visual,
        ["]A"] = path_actions.insert_abspath_A_visual,
        ["]o"] = path_actions.insert_abspath_o_visual,
        ["]O"] = path_actions.insert_abspath_O_visual,
        -- Additionally, there's insert and normal mode mappings for the same actions:
        ["{i"] = path_actions.insert_relpath_i_insert,
        ["{I"] = path_actions.insert_relpath_I_insert,
        ["{a"] = path_actions.insert_relpath_a_insert,
        ["{A"] = path_actions.insert_relpath_A_insert,
        ["{o"] = path_actions.insert_relpath_o_insert,
        ["{O"] = path_actions.insert_relpath_O_insert,
        ["}i"] = path_actions.insert_abspath_i_insert,
        ["}I"] = path_actions.insert_abspath_I_insert,
        ["}a"] = path_actions.insert_abspath_a_insert,
        ["}A"] = path_actions.insert_abspath_A_insert,
        ["}o"] = path_actions.insert_abspath_o_insert,
        ["}O"] = path_actions.insert_abspath_O_insert,
        ["-i"] = path_actions.insert_relpath_i_normal,
        ["-I"] = path_actions.insert_relpath_I_normal,
        ["-a"] = path_actions.insert_relpath_a_normal,
        ["-A"] = path_actions.insert_relpath_A_normal,
        ["-o"] = path_actions.insert_relpath_o_normal,
        ["-O"] = path_actions.insert_relpath_O_normal,
        ["+i"] = path_actions.insert_abspath_i_normal,
        ["+I"] = path_actions.insert_abspath_I_normal,
        ["+a"] = path_actions.insert_abspath_a_normal,
        ["+A"] = path_actions.insert_abspath_A_normal,
        ["+o"] = path_actions.insert_abspath_o_normal,
        ["+O"] = path_actions.insert_abspath_O_normal,
      },
    },
    file_ignore_patterns = { "^.git/", ".cache/" },
  },
  pickers = {
    find_files = {
      hidden = true,
    },
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
telescope.load_extension("harpoon")
telescope.load_extension("neoclip")
