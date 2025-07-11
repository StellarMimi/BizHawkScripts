-- Some code for how I used to do splitting. Useful for other reasons so don't want to delete it.
-- Will not work as is

local function bits(n)
	local t = {}
	for i=7,0,-1 do
	  t[#t+1] = math.floor(n / 2^i)
	  n = n % 2^i
	end
	return table.concat(t)
end

local function get_game_status()
	local missile_status = monitored_values[MISSILE_STATUS_ADDR] or mainmemory.readbyte(MISSILE_STATUS_ADDR)
	local beam_status = monitored_values[BEAM_STATUS_ADDR] or mainmemory.readbyte(BEAM_STATUS_ADDR)
	local misc_suit_status = monitored_values[MISC_SUIT_STATUS_ADDR] or mainmemory.readbyte(MISC_SUIT_STATUS_ADDR)

	local main_deck_status = monitored_values[MAIN_DECK_COMPLETION_ADDR] or mainmemory.readbyte(MAIN_DECK_COMPLETION_ADDR)
	local sec_1_status = monitored_values[SEC_1_COMPLETION_ADDR] or mainmemory.readbyte(SEC_1_COMPLETION_ADDR)
	local sec_2_status = monitored_values[SEC_2_COMPLETION_ADDR] or mainmemory.readbyte(SEC_2_COMPLETION_ADDR)
	local sec_3_status = monitored_values[SEC_3_COMPLETION_ADDR] or mainmemory.readbyte(SEC_3_COMPLETION_ADDR)
	local sec_4_status = monitored_values[SEC_4_COMPLETION_ADDR] or mainmemory.readbyte(SEC_4_COMPLETION_ADDR)
	local sec_5_status = monitored_values[SEC_5_COMPLETION_ADDR] or mainmemory.readbyte(SEC_5_COMPLETION_ADDR)
	local sec_6_status = monitored_values[SEC_6_COMPLETION_ADDR] or mainmemory.readbyte(SEC_6_COMPLETION_ADDR)

	if LOG_LEVEL >= 3 then
		print("Getting Upgrades List... \n")
		print("Missile Status:", bits(missile_status))
		print("Beam Upgrade Status:", bits(beam_status))
		print("Misc Suit Status:", bits(misc_suit_status))
		print("MainDeck Completion:", string.format("%d/13", main_deck_status), string.format("%.1f %%", main_deck_status * 100 / 13))
		print("Sec 1 Completion:", string.format("%d/12", sec_1_status), string.format("%.1f %%", sec_1_status * 100 / 12))
		print("Sec 2 Completion:", string.format("%d/17", sec_2_status), string.format("%.1f %%", sec_2_status * 100 / 17))
		print("Sec 3 Completion:", string.format("%d/16", sec_3_status), string.format("%.1f %%", sec_3_status * 100 / 16))
		print("Sec 4 Completion:", string.format("%d/15", sec_4_status), string.format("%.1f %%", sec_4_status * 100 / 15))
		print("Sec 5 Completion:", string.format("%d/15", sec_5_status), string.format("%.1f %%", sec_5_status * 100 / 15))
		print("Sec 6 Completion:", string.format("%d/12", sec_6_status), string.format("%.1f %%", sec_6_status * 100 / 12))
		print("Final Completion:", string.format("%d %%", (main_deck_status + sec_1_status + sec_2_status + sec_3_status + sec_4_status + sec_5_status + sec_6_status)))
		print("")
	end

	local new_upgrades = {}
	local new_completed_locations = {}
	local new_split_index = 0

	if missile_status & 0x01 ~= 0x0 then
		table.insert(new_upgrades, "Missile")

		-- Change these if you need your split index to be different
		new_split_index = math.max(new_split_index, 1)
	end

	if missile_status & 0x02 ~= 0x0 then
		table.insert(new_upgrades, "Super Missile")
		new_split_index = math.max(new_split_index, 7)
	end

	if missile_status & 0x04 ~= 0x0 then
		table.insert(new_upgrades, "Ice Missles")
		new_split_index = math.max(new_split_index, 9)
	end

	if missile_status & 0x08 ~= 0x0 then
		table.insert(new_upgrades, "Diffusion Missiles")
		new_split_index = math.max(new_split_index, 15)
	end

	if missile_status & 0x10 ~= 0x0 then
		table.insert(new_upgrades, "Bombs")
		new_split_index = math.max(new_split_index, 4)
	end

	if missile_status & 0x20 ~= 0x0 then
		table.insert(new_upgrades, "Power Bomb")
		new_split_index = math.max(new_split_index, 11)
	end

	if misc_suit_status & 0x01 ~= 0x0 then
		table.insert(new_upgrades, "Hi-Jump")
		new_split_index = math.max(new_split_index, 5)
	end

	if misc_suit_status & 0x02 ~= 0x0 then
		table.insert(new_upgrades, "Speed Booster")
		new_split_index = math.max(new_split_index, 6)
	end

    if misc_suit_status & 0x04 ~= 0x0 then
		table.insert(new_upgrades, "Space Jump")
		new_split_index = math.max(new_split_index, 12)
	end

	if misc_suit_status & 0x08 ~= 0x0 then
		table.insert(new_upgrades, "Screw Attack")
		new_split_index = math.max(new_split_index, 18)
	end

	if misc_suit_status & 0x10 ~= 0x0 then
		table.insert(new_upgrades, "Varia Suit")
		new_split_index = math.max(new_split_index, 8)
	end

	if misc_suit_status & 0x20 ~= 0x0 then
		table.insert(new_upgrades, "Gravity Suit")
		new_split_index = math.max(new_split_index, 14)
	end

	if misc_suit_status & 0x40 ~= 0x0 then
		table.insert(new_upgrades, "Morph Ball")
		new_split_index = math.max(new_split_index, 2)
	end

	if beam_status & 0x01 ~= 0x0 then
		table.insert(new_upgrades, "Charge Beam")
		new_split_index = math.max(new_split_index, 3)
	end

	if beam_status & 0x02 ~= 0x0 then
		table.insert(new_upgrades, "Wide Beam")
		new_split_index = math.max(new_split_index, 10)
	end

	if beam_status & 0x04 ~= 0x0 then
		table.insert(new_upgrades, "Plasma Beam")
		new_split_index = math.max(new_split_index, 13)
	end

	if beam_status & 0x08 ~= 0x0 then
		table.insert(new_upgrades, "Wave Beam")
		new_split_index = math.max(new_split_index, 17)
	end

	if main_deck_status == 0x0D then
		table.insert(new_completed_locations, "Main Deck")
		new_split_index = math.max(new_split_index, 24)
	end

	if sec_1_status == 0x0C then
		table.insert(new_completed_locations, "Sector 1")
		new_split_index = math.max(new_split_index, 22)
	end

	if sec_2_status == 0x11 then
		table.insert(new_completed_locations, "Sector 2")
		new_split_index = math.max(new_split_index, 23)
	end

	if sec_3_status == 0x10 then
		table.insert(new_completed_locations, "Sector 3")
		new_split_index = math.max(new_split_index, 19)
	end

	if sec_4_status == 0x0F then
		table.insert(new_completed_locations, "Sector 4")
		new_split_index = math.max(new_split_index, 16)
	end

	if sec_5_status == 0x0F then
		table.insert(new_completed_locations, "Sector 5")
		new_split_index = math.max(new_split_index, 20)
	end

	if sec_6_status == 0x0C then
		table.insert(new_completed_locations, "Sector 6")
		new_split_index = math.max(new_split_index, 21)
	end

	return new_upgrades, new_split_index, new_completed_locations
end

local function sync() 
	local current_upgrades, split_index = get_game_status()

	if split_index - current_split_index > 1 then
		print("Split Index of 2 or Greater Mismatch Detected!")
		print("Current Split Index: " .. current_split_index)
		print("Updated Split Index: " .. split_index)
		print("Attempting to recover...")

		recover_status()
	elseif split_index - current_split_index == 1 then
		print("Split!")
		pipe_write("split")
		current_split_index = split_index
	end
end


local function check_for_final(addr, val, flags)
	if (val ~= 0x20) then
		return
	end

	if monitored_values[FOREGROUND_PROPERTIES_ADDR] ~= 0x4A then
		return
	end

	if LOG_LEVEL >= 1 then
		print("Final Split!")
	end

	pipe_write("split")
end