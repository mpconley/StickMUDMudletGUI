function round(n)
	return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
end

function CharVitals()
	-- Use safe GMCP access with defaults
	local current_hp = GMCPSafe.getNumber("Char.Vitals.hp", 0)
	local max_hp = GMCPSafe.getNumber("Char.Vitals.maxhp", 1)
	local current_sp = GMCPSafe.getNumber("Char.Vitals.sp", 0)
	local max_sp = GMCPSafe.getNumber("Char.Vitals.maxsp", 1)
	local current_fp = GMCPSafe.getNumber("Char.Vitals.fp", 0)
	local max_fp = GMCPSafe.getNumber("Char.Vitals.maxfp", 1)
	
	-- Ensure max values are never zero to prevent division by zero
	if max_hp <= 0 then max_hp = 1 end
	if max_sp <= 0 then max_sp = 1 end
	if max_fp <= 0 then max_fp = 1 end
	
	local percent_hp = round(tonumber(current_hp / max_hp * 100))
	local percent_sp = round(tonumber(current_sp / max_sp * 100))
	local percent_fp = round(tonumber(current_fp / max_fp * 100))

	percent_hp = percent_hp.."%"
	if string.cut(percent_hp, 1) == "-" then percent_hp = "0%" end
	if current_hp > max_hp then current_hp = max_hp end
  
	GUI.HitPoints:setValue(current_hp, max_hp, ("<center><b>" ..current_hp.. "/" ..max_hp.. " Hit (" ..percent_hp.. ")</b></center>"))	
	
	percent_sp = percent_sp.."%"
	if string.cut(percent_sp, 1) == "-" then percent_sp = "0%" end
	if current_sp > max_sp then current_sp = max_sp end

	GUI.SpellPoints:setValue(current_sp, max_sp, ("<center><b>" ..current_sp.. "/" ..max_sp.. " Spell (" ..percent_sp.. ")</b></center>"))	

	percent_fp = percent_fp.."%"
	if string.cut(percent_fp, 1) == "-" then percent_fp = "0%" end
	if current_fp > max_fp then current_fp = max_fp end

	GUI.FatiguePoints:setValue(current_fp, max_fp, ("<span style = 'color: black'><center><b>" ..current_fp.. "/" ..max_fp.. " Fatigue (" ..percent_fp.. ")</b></center></span>"))	
end