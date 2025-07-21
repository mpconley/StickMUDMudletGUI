function CharItemsAddLocationInv()
  if GMCPSafe.getString("Char.Items.Add.location", "") == "inv" then
    local value = GMCPSafe.getTable("Char.Items.Add.item", {})
    if not value or not value.id or not value.name then
      return -- Skip if item data is incomplete
    end
    local highlight = getItemHighlight(value) or ""
    if value.attrib == "w" then
      wornArmour[value.id] = highlight .. value.name
    elseif value.attrib == "l" then
      wieldedWeapons[value.id] = highlight .. value.name
    else
      otherInventory[value.id] = highlight .. value.name
    end
    UpdateInventoryConsole()
  end
end