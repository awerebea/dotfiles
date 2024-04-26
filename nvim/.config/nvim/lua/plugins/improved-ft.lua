return {
  "backdround/improved-ft.nvim",
  -- enabled = not require("utils").is_windows(),
  enabled = false,
  event = "VeryLazy",
  config = function()
    local ft = require "improved-ft"
    ft.setup {
      -- Maps default f/F/t/T/;/, keys, default: false
      use_default_mappings = true,
      -- Ignores case of the given characters, default: false.
      ignore_char_case = false,
      -- Takes a last jump direction into account during repetition jumps, default: false.
      use_relative_repetition = true,
    }

    local imap = function(key, fn, description)
      vim.keymap.set("i", key, fn, { desc = description })
    end

    imap("<M-f>", ft.hop_forward_to_char, "Hop forward to a given char")
    imap("<M-F>", ft.hop_backward_to_char, "Hop backward to a given char")

    imap("<M-t>", ft.hop_forward_to_pre_char, "Hop forward before a given char")
    imap("<M-T>", ft.hop_backward_to_pre_char, "Hop backward before a given char")

    imap("<M-;>", ft.repeat_forward, "Repeat hop forward to a last given char")
    imap("<M-,>", ft.repeat_backward, "Repeat hop backward to a last given char")
  end,
}
