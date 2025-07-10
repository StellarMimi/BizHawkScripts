local LOG_LEVEL <const> = 3

local GAME_STATUS_ADDR <const> = 0x0018;
local MISSILE_STATUS_ADDR <const> = 0x134F;
local BEAM_STATUS_ADDR <const> = 0x134E;
local MISC_SUIT_STATUS_ADDR <const> = 0x1350;

local IWRAM_ADDR <const> = 0x03000000;

local upgrades = {}
local current_split_index = 0

local monitored_values = {}

local function bits(n)
	local t = {}
	for i=7,0,-1 do
	  t[#t+1] = math.floor(n / 2^i)
	  n = n % 2^i
	end
	return table.concat(t)
end


local function pipe_write(data)
	if LOG_LEVEL >= 3 then
		print("LiveSplit Write:", data)
	end

	pipe_handle:write(string.format("%s\r\n", data))
	pipe_handle:flush()
end

local function pipe_read()
	local line = pipe_handle:read("*l")
	
	if not line then
		if LOG_LEVEL >= 3 then
			print("LiveSplit Empty Read")
		end
		return nil
	end

	if LOG_LEVEL >= 3 then
		print("LiveSplit Read:", line)
	end

	return line
end

local function get_upgrades_list()
	local missile_status = monitored_values[MISSILE_STATUS_ADDR] or mainmemory.readbyte(MISSILE_STATUS_ADDR)
	local beam_status = monitored_values[BEAM_STATUS_ADDR] or mainmemory.readbyte(BEAM_STATUS_ADDR)
	local misc_suit_status = monitored_values[MISC_SUIT_STATUS_ADDR] or mainmemory.readbyte(MISC_SUIT_STATUS_ADDR)

	if LOG_LEVEL >= 3 then
		print("Getting Upgrades List... \n")
		print("Missile Status:", bits(missile_status))
		print("Beam Upgrade Status:", bits(beam_status))
		print("Misc Suit Status:", bits(misc_suit_status))
		print("")
	end

	local new_upgrades = {}
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
		new_split_index = math.max(new_split_index, 17)
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
		new_split_index = math.max(new_split_index, 16)
	end

	return new_upgrades, new_split_index
end

local function recover_status()
	monitored_values[MISSILE_STATUS_ADDR] = mainmemory.readbyte(MISSILE_STATUS_ADDR)
	monitored_values[BEAM_STATUS_ADDR] = mainmemory.readbyte(BEAM_STATUS_ADDR)
	monitored_values[MISC_SUIT_STATUS_ADDR] = mainmemory.readbyte(MISC_SUIT_STATUS_ADDR)

	local current_upgrades, split_index = get_upgrades_list()

	if #current_upgrades > 0 then
		print("Found upgrades: ")
		for _, current_upgrades in ipairs(current_upgrades) do
			print(" - " .. current_upgrades)
		end
		print("")
	end

	pipe_write("getsplitindex")
	local livesplit_status = tonumber(pipe_read())

	if livesplit_status == -1 then
		pipe_write("starttimer")
		-- To not have to requery it for the upcoming math.
		livesplit_status = 0
	end

	if LOG_LEVEL >= 1 then
		print("Current Split Index: " .. current_split_index)
		print("Updated Split Index: " .. split_index)
	end
	
	local index_to_skip_to = split_index - livesplit_status
	current_split_index = split_index

	if index_to_skip_to < 0 then
		while index_to_skip_to < 0 do
			pipe_write("unsplit")
			index_to_skip_to = index_to_skip_to + 1
		end
	else
		while index_to_skip_to > 0 do
			pipe_write("skipsplit")
			index_to_skip_to = index_to_skip_to - 1
		end
	end
end

local function sync() 
	local current_upgrades, split_index = get_upgrades_list()

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

local function init_livesplit()
    pipe_handle = io.open("//./pipe/LiveSplit", 'a+')

    if not pipe_handle then
        error("\nFailed to open LiveSplit named pipe!\n" ..
              "Please make sure LiveSplit is running and is at least 1.7, " ..
              "then load this script again")
    end

	local game_active = mainmemory.readbyte(GAME_STATUS_ADDR)

	if (game_active == 0x0) then
		pipe_write("reset")
    else 
		print("Fusion 100% Autosplitter Started Mid-Game, Recovering at best ability... \n")
		recover_status()
	end
	
    return pipe_handle
end

local function start_and_stop_game(addr, val, flags)
	if LOG_LEVEL >= 3 then
		print("Game Status Change", string.format("0x%x", val))
	end

	if val == 2 then
		pipe_write("starttimer")
	elseif val == 0 then
		pipe_write("reset")
	end
end

local function monitor_value(addr, val, flags) 
	local short_addr = addr - IWRAM_ADDR

	if (val == monitored_values[short_addr]) then
		return
	end

	monitored_values[short_addr] = val
	
	if LOG_LEVEL >= 3 then
		print("Monitored Value Changed", string.format("0x%x: 0x%x", short_addr, monitored_values[short_addr]))
	end

	sync()
end

console.clear()
pipe_handle = init_livesplit()

if LOG_LEVEL >= 3 then
	print("Working Memory Type: ", mainmemory.getname())
end

event.on_bus_write(start_and_stop_game, GAME_STATUS_ADDR + IWRAM_ADDR)

event.on_bus_write(monitor_value, MISSILE_STATUS_ADDR + IWRAM_ADDR)
event.on_bus_write(monitor_value, BEAM_STATUS_ADDR + IWRAM_ADDR)
event.on_bus_write(monitor_value, MISC_SUIT_STATUS_ADDR + IWRAM_ADDR)

local function load_state()
	console.clear()
	print("Load State Detected, recovering status...\n")
	recover_status()
end

event.onloadstate(load_state)

-- Required to keep events firing.
while true do
	emu.frameadvance();
end
