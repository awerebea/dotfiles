-- real-icons.nvim: real image file icons rendered with the Kitty graphics
-- protocol (Kitty and Ghostty, also inside tmux), with an automatic glyph
-- fallback everywhere else, so this config stays usable in any terminal.
--
-- Needs the `magick` binary (ImageMagick) plus curl/tar for `:RealIcons
-- install`, which downloads the Material Icon Theme pack. Without the pack the
-- plugin falls back to its small bundled one. `:RealIcons health` reports what
-- the current terminal supports, `:RealIcons demo` renders a sample buffer.

-- Images inside tmux are sent as a passthrough DCS sequence, which tmux only
-- forwards while `allow-passthrough` is on or all (set in
-- tmux/.tmux.conf.local). With it off the icons would render as blanks, so keep
-- glyphs in that case instead of disabling the plugin.
local function images_available()
  if not vim.env.TMUX or vim.env.TMUX == "" then
    return true
  end

  local output = vim.fn.system({ "tmux", "show", "-gv", "allow-passthrough" })
  if vim.v.shell_error ~= 0 then
    return false
  end

  output = vim.trim(output)
  return output == "on" or output == "all"
end

-- Enabling an integration requires modules of its host plugin, so it must not
-- happen in `opts` below: that would drag every host plugin into startup. It
-- also cannot wait for the `User LazyLoad` event, which lazy.nvim fires from a
-- `vim.schedule()` callback, i.e. after a `cmd`/`keys` trigger has already
-- opened the picker or the file explorer that should show the icons.
--
-- lazy.nvim resolves `opts` immediately before it runs a plugin's `config`, so
-- an `opts` function is the hook that runs late enough for the host modules to
-- be loadable and early enough for integrations that wrap a `setup()` function
-- (lualine, nvim-tree). The merged opts are passed through untouched.
local function integration(plugin, name)
  return {
    plugin,
    optional = true,
    opts = function(_, opts)
      local ok, real_icons = pcall(require, "real-icons")
      if ok then
        pcall(real_icons.enable_integration, name)
      end
      return opts
    end,
  }
end

return {
  {
    "Mirsmog/real-icons.nvim",
    lazy = false,
    build = ":RealIcons install",
    opts = {
      pack = "material",
      -- false disables image rendering and leaves only the glyph fallback
      backend = images_available() and "auto" or false,
      fallback = {
        enabled = true,
        -- nvim-web-devicons is the icon provider used everywhere else in this
        -- config, so pin it: "auto" prefers mini.icons as soon as any other
        -- plugin (whichkey, fyler) has loaded it, which changes the glyphs
        provider = "devicons",
      },
    },
  },

  -- Integrations for the plugins of this config. Not available for tabby,
  -- fyler, grapple or the custom telescope entry makers in
  -- plugins/telescope/telescopePickers.lua, and skipped for the plugins this
  -- config does not use: bufferline, mini.files, neo-tree,
  -- telescope-file-browser.
  integration("nvim-lualine/lualine.nvim", "lualine"),
  integration("nvim-tree/nvim-tree.lua", "nvim_tree"),
  integration("stevearc/oil.nvim", "oil"),
  integration("nvim-telescope/telescope.nvim", "telescope"),
  integration("ibhagwan/fzf-lua", "fzf_lua"),
  integration("folke/snacks.nvim", "snacks_picker"),
}
