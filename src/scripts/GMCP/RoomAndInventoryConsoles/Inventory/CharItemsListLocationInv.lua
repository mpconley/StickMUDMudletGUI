function CharItemsListLocationInv()
  if GMCPSafe.getString("Char.Items.List.location", "") == "inv" then
    wornArmour = {}
    wieldedWeapons = {}
		otherInventory = {}
    local items = GMCPSafe.getTable("Char.Items.List.items", {})
    if (items and next(items) ~= nil) then
      for key, value in pairs(items) do
        local highlight = getItemHighlight(value) or ""
        if value.attrib == "w" then
          wornArmour[value.id] = highlight .. value.name
        elseif value.attrib == "l" then
          wieldedWeapons[value.id] = highlight .. value.name
        else
          otherInventory[value.id] = highlight .. value.name
        end
      end
    end
    UpdateInventoryConsole()
  end
end