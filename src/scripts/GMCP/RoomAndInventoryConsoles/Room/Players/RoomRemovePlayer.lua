function RoomRemovePlayer()
  local playerKey = GMCPSafe.getString("Room.RemovePlayer", "")
  if playerKey == "" then
    return -- Skip if no player key provided
  end
  
  roomPlayersTable["" .. playerKey] = nil
  UpdateRoomConsole()
end