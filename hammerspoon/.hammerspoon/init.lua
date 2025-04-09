-- Move window to next screen
hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "Right", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local nextScreen = win:screen():next()
  win:moveToScreen(nextScreen)
end)

-- Move window to previous screen
hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "Left", function()
  local win = hs.window.focusedWindow()
  if not win then return end
  local prevScreen = win:screen():previous()
  win:moveToScreen(prevScreen)
end)

-- App hotkeys
local appHotkeys = {
  { mods = { "ctrl", "alt" }, key = "x", app = "kitty", path = "/Applications/kitty.app", bundleID = "net.kovidgoyal.kitty" },
  { mods = { "ctrl", "alt" }, key = "c", app = "Google Chrome", path = "/Applications/Google Chrome.app", bundleID = "com.google.Chrome" },
  { mods = { "ctrl", "alt" }, key = "f", app = "Firefox", path = "/Applications/Firefox.app", bundleID = "org.mozilla.firefox" },
  { mods = { "ctrl", "alt" }, key = "v", app = "Code", path = "/Applications/Visual Studio Code.app", bundleID = "com.microsoft.VSCode" },
  { mods = { "ctrl", "alt" }, key = "q", app = "Calculator", path = "/System/Applications/Calculator.app", bundleID = "com.apple.calculator" },
  { mods = { "ctrl", "alt" }, key = "s", app = "Slack", path = "/Applications/Slack.app", bundleID = "com.tinyspeck.slackmacgap" },
  { mods = { "ctrl", "alt" }, key = "o", app = "Obsidian", path = "/Applications/Obsidian.app", bundleID = "md.obsidian" },
  { mods = { "ctrl", "alt" }, key = "b", app = "Bitwarden", path = "/Applications/Bitwarden.app", bundleID = "com.bitwarden.desktop" },
  { mods = { "ctrl", "alt" }, key = "k", app = "KeePassXC", path = "/Applications/KeePassXC.app", bundleID = "org.keepassx.keepassxc" },
  { mods = { "ctrl", "alt" }, key = "u", app = "Microsoft Outlook", path = "/Applications/Microsoft Outlook.app", bundleID = "com.microsoft.Outlook" },
  { mods = { "ctrl", "alt" }, key = "e", app = "TextEdit", path = "/System/Applications/TextEdit.app", bundleID = "com.apple.TextEdit" },
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
      if item.path and hs.fs.attributes(item.path) then
        hs.task.new("/usr/bin/open", nil, { "-a", item.path }):start()
      elseif item.bundleID then
        hs.application.launchOrFocusByBundleID(item.bundleID)
      else
        hs.application.launchOrFocus(item.app)
      end
    end
  end)
end
