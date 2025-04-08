local appHotkeys = {
  { mods = { "ctrl", "alt" }, key = "x", app = "kitty" },
  { mods = { "ctrl", "alt" }, key = "c", app = "Google Chrome" },
  { mods = { "ctrl", "alt" }, key = "f", app = "Firefox" },
  { mods = { "ctrl", "alt" }, key = "v", app = "Code" },
  { mods = { "ctrl", "alt" }, key = "q", app = "Calculator" },
  { mods = { "ctrl", "alt" }, key = "s", app = "Slack" },
  { mods = { "ctrl", "alt" }, key = "o", app = "Obsidian" },
  { mods = { "ctrl", "alt" }, key = "b", app = "Bitwarden" },
  { mods = { "ctrl", "alt" }, key = "k", app = "KeePassXC" },
  { mods = { "ctrl", "alt" }, key = "u", app = "Microsoft Outlook" },
  { mods = { "ctrl", "alt" }, key = "e", app = "TextEdit" },
}

for _, item in ipairs(appHotkeys) do
  hs.hotkey.bind(item.mods, item.key, function()
    local app = hs.application.get(item.app)

    if app then
      local windows = app:allWindows()
      local targetWindow = nil

      for _, win in ipairs(windows) do
        if win:isStandard() then
          targetWindow = win
          break
        end
      end

      if targetWindow then
        if targetWindow:isMinimized() then
          targetWindow:unminimize()
          hs.timer.doAfter(0.1, function()
            app:activate()
            app:unhide()
            targetWindow:focus()
          end)
        elseif app:isFrontmost() then
          targetWindow:minimize()
        else
          app:activate()
          app:unhide()
          targetWindow:focus()
        end
      else
        app:activate()
        app:unhide()
      end
    else
      hs.application.launchOrFocus(item.app)
    end
  end)
end
