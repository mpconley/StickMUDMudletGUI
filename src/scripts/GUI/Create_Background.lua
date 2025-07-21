-- Enhanced responsive background layout
GUI.Right = Geyser.Label:new({
  name = "GUI.Right",
  x = "-40%", y = 0,
  width = "40%",
  height = "100%",
})
setBackgroundColor("GUI.Right", 0, 0, 0)

GUI.Top = Geyser.Label:new({
  name = "GUI.Top",
  x = 0, y = 0,
  width = "60%",
  height = "7%",
})
setBackgroundColor("GUI.Top", 0, 0, 0)

GUI.Bottom = Geyser.Label:new({
  name = "GUI.Bottom",
  x = 0, y = "90%",
  width = "60%",
  height = "10%",
})
setBackgroundColor("GUI.Bottom", 0, 0, 0)

-- Add resize handlers for background elements
if GUI.WindowResize then
    GUI.WindowResize.backgroundElements = {GUI.Right, GUI.Top, GUI.Bottom}
end