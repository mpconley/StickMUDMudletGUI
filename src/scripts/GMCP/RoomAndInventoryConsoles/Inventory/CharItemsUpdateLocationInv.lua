function CharItemsUpdateLocationInv()
  if GMCPSafe.getString("Char.Items.Update.location", "") == "inv" then
    local value = GMCPSafe.getTable("Char.Items.Update.item", {})
    if not value or not value.id or not value.name then
      return -- Skip if item data is incomplete
    end
    
		local itemKey = value.id
    local highlight = getItemHighlight(value) or ""
    if value.attrib == "w" then
      wornArmour[value.id] = highlight .. value.name
			otherInventory["" .. value.id] = nil
    elseif value.attrib == "l" then
      wieldedWeapons[value.id] = highlight .. value.name
			otherInventory["" .. value.id] = nil
    else
      otherInventory[value.id] = highlight .. value.name
			wornArmour["" .. value.id] = nil
			wieldedWeapons["" .. value.id] = nil
    end
    UpdateInventoryConsole()
  end
end