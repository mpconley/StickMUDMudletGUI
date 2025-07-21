function RoomAddPlayer()
  local value = GMCPSafe.getTable("Room.AddPlayer", {})
  if not value or not value.name or not value.fullname then
    return -- Skip if player data is incomplete
  end
  
  local highlight = getPlayerHighlight(value) or ""
  roomPlayersTable[value.name] = highlight .. value.fullname
  UpdateRoomConsole()
end