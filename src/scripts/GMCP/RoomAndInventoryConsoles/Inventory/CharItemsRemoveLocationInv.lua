function CharItemsRemoveLocationInv()
  if GMCPSafe.getString("Char.Items.Remove.location", "") == "inv" then
    local item = GMCPSafe.getTable("Char.Items.Remove.item", {})
    if not item or not item.id then
      return -- Skip if item data is incomplete
    end
    
    itemKey = item.id
    wornArmour["" .. itemKey] = nil
    wieldedWeapons["" .. itemKey] = nil
    otherInventory["" .. itemKey] = nil
    UpdateInventoryConsole()
  end
end