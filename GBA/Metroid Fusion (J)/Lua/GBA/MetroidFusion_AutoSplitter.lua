local LOG_LEVEL <const> = 0

local GAME_STATUS_ADDR <const> = 0x0018;
local MISSILE_STATUS_ADDR <const> = 0x134F;
local BEAM_STATUS_ADDR <const> = 0x134E;
local MISC_SUIT_STATUS_ADDR <const> = 0x1350;

local MAIN_DECK_COMPLETION_ADDR <const> = 0x0041; -- 100% is 13/0x0D
local SEC_1_COMPLETION_ADDR <const> = 0x0042; -- 100% is 12/0x0C
local SEC_2_COMPLETION_ADDR <const> = 0x0043; -- 100% is 17/0x11
local SEC_3_COMPLETION_ADDR <const> = 0x0044; -- 100% is 16/0x10
local SEC_4_COMPLETION_ADDR <const> = 0x0045; -- 100% is 15/0x0F
local SEC_5_COMPLETION_ADDR <const> = 0x0046; -- 100% is 15/0x0F
local SEC_6_COMPLETION_ADDR <const> = 0x0047; -- 100% is 12/0x0C

local GAMEMODE_ADDR <const> = 0x0C12; -- 0x0D is Demo for JP unlike RAM map says, ignore all sync requests
local FOREGROUND_PROPERTIES_ADDR <const> = 0x00A9; -- 0x4A is Omega Metroid Room
local SAMUS_POSE_ADDR <const> = 0x1279; -- 0x20 when getting sucked into the ship for final time.

local IWRAM_ADDR_OFFSET <const> = 0x03000000;

local current_split_index = 0 -- Freshly Reset

-- Each line here is a split that will be sent to LiveSplit.
local splits = {
	-- Start
	{ ["iw_addr"]= GAMEMODE_ADDR, ["operand"]= "transform", ["valueFrom"]= 0x07, ["value"]= 0x03 },
	-- Missle
	{ ["iw_addr"]= MISSILE_STATUS_ADDR, ["operand"]= "bit_and", ["value"]= 0x01 },
	-- Morph Ball
	{ ["iw_addr"]= MISC_SUIT_STATUS_ADDR, ["operand"]= "bit_and", ["value"]= 0x40 },
	-- Charge Beam
	{ ["iw_addr"]= BEAM_STATUS_ADDR, ["operand"]= "bit_and", ["value"]= 0x01 },
	-- Bomb
	{ ["iw_addr"]= MISSILE_STATUS_ADDR, ["operand"]= "bit_and", ["value"]= 0x10 },
	-- Hi-Jump
	{ ["iw_addr"]= MISC_SUIT_STATUS_ADDR, ["operand"]= "bit_and", ["value"]= 0x01 },
	-- Speed Booster
	{ ["iw_addr"]= MISC_SUIT_STATUS_ADDR, ["operand"]= "bit_and", ["value"]= 0x02 },
	-- Super Missles
	{ ["iw_addr"]= MISSILE_STATUS_ADDR, ["operand"]= "bit_and", ["value"]= 0x02 },
	-- Varia Suit
	{ ["iw_addr"]= MISC_SUIT_STATUS_ADDR, ["operand"]= "bit_and", ["value"]= 0x10 },
	-- Ice Missles
	{ ["iw_addr"]= MISSILE_STATUS_ADDR, ["operand"]= "bit_and", ["value"]= 0x04 },
	-- Wide Beam
	{ ["iw_addr"]= BEAM_STATUS_ADDR, ["operand"]= "bit_and", ["value"]= 0x02 },
	-- Power Bomb
	{ ["iw_addr"]= MISSILE_STATUS_ADDR, ["operand"]= "bit_and", ["value"]= 0x20 },
	-- Space Jump
	{ ["iw_addr"]= MISC_SUIT_STATUS_ADDR, ["operand"]= "bit_and", ["value"]= 0x04 },
	-- Plasma Beam
	{ ["iw_addr"]= BEAM_STATUS_ADDR, ["operand"]= "bit_and", ["value"]= 0x04 },
	-- Gravity Suit
	{ ["iw_addr"]= MISC_SUIT_STATUS_ADDR, ["operand"]= "bit_and", ["value"]= 0x20 },
	-- Diffusion Missiles
	{ ["iw_addr"]= MISSILE_STATUS_ADDR, ["operand"]= "bit_and", ["value"]= 0x08 },
	-- Sector 4 100%
	{ ["iw_addr"]= SEC_4_COMPLETION_ADDR, ["operand"]= "eq", ["value"]= 0x0F },
	-- Wave Beam
	{ ["iw_addr"]= BEAM_STATUS_ADDR, ["operand"]= "bit_and", ["value"]= 0x08 },
	-- Screw Attack
	{ ["iw_addr"]= MISC_SUIT_STATUS_ADDR, ["operand"]= "bit_and", ["value"]= 0x08 },
	-- Sector 3 100%
	{ ["iw_addr"]= SEC_3_COMPLETION_ADDR, ["operand"]= "eq", ["value"]= 0x10 },
	-- Sector 5 100%
	{ ["iw_addr"]= SEC_5_COMPLETION_ADDR, ["operand"]= "eq", ["value"]= 0x0F },
	-- Sector 6 100%
	{ ["iw_addr"]= SEC_6_COMPLETION_ADDR, ["operand"]= "eq", ["value"]= 0x0C },
	-- Sector 1 100%
	{ ["iw_addr"]= SEC_1_COMPLETION_ADDR, ["operand"]= "eq", ["value"]= 0x0C },
	-- Sector 2 100%
	{ ["iw_addr"]= SEC_2_COMPLETION_ADDR, ["operand"]= "eq", ["value"]= 0x11 },
	-- Main Deck 100%
	{ ["iw_addr"]= MAIN_DECK_COMPLETION_ADDR, ["operand"]= "eq", ["value"]= 0x0D },
	-- End
	{ ["iw_addr"]= FOREGROUND_PROPERTIES_ADDR, ["operand"]= "final", ["value"]= 0x4A }, 
}

local monitored_values = {}

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

local function check_split_by_memory(split) 
	local value = mainmemory.readbyte(split["iw_addr"])

	if LOG_LEVEL >= 3 then
		print(string.format("Checking split @0x%x: 0x%x %s 0x%x", split["iw_addr"], value, split["operand"], split["value"]))
	end

	if split["operand"] == "bit_and" then
		return (value & split["value"]) == split["value"]
	elseif split["operand"] == "eq" then
		return value == split["value"]
	elseif split["operand"] == "final" then
		-- Why are you running this on a completed game?
		if mainmemory.readbyte(GAMEMODE_ADDR) == 0x0A then
			pipe_write("reset")
			current_split_index = 0
		end

		return false
	else
		error("Unknown operand: " .. split["operand"])
	end
end

local transform_op_storage = 0;
local active_callback = nil;

local function arm_split(split)
	local iw_addr = split["iw_addr"]
	local operand = split["operand"]
	local value = split["value"]
	local callback_name	= string.format("livesplit-%x-%s-%x",iw_addr, operand, value)
	active_callback = callback_name

	if LOG_LEVEL >= 3 then
		print(string.format("Arming split %s", callback_name))
	end

	local function send_split()
		current_split_index = current_split_index + 1
		pipe_write("startorsplit")
		event.unregisterbyname(active_callback)
		arm_split(splits[current_split_index + 1])
	end

	if (operand == "bit_and") then
		event.on_bus_write(function (addr, val, flags)
			if val & value == value then
				send_split()
			end
		end, iw_addr + IWRAM_ADDR_OFFSET, callback_name)
	elseif (operand == "eq") then
		event.on_bus_write(function (addr, val, flags)
			if val == value then
				send_split()
			end
		end, iw_addr + IWRAM_ADDR_OFFSET, callback_name)
	elseif (operand == "transform") then
		local value_from = split["valueFrom"]
		transform_op_storage = mainmemory.readbyte(iw_addr)

		event.on_bus_write(function (addr, val, flags)
			if val == value and transform_op_storage == value_from then
				send_split()
			else
				transform_op_storage = val
			end
		end, iw_addr + IWRAM_ADDR_OFFSET, callback_name)
	elseif (operand == "final") then
		local room_callback_name = callback_name .. "-check_for_final_room"

		-- Are we already in the final room?
		if mainmemory.readbyte(FOREGROUND_PROPERTIES_ADDR) == 0x4A then
			-- Wait for the pose.
			event.on_bus_write(function (addr, val, flags) 
				if val == 0x20 then
					pipe_write("split")
					event.unregisterbyname(callback_name)
				end
			end, SAMUS_POSE_ADDR + IWRAM_ADDR_OFFSET, callback_name)
		else
			active_callback = room_callback_name
			-- Wait for final room.
			event.on_bus_write(function (addr, val, flags)
				if val == 0x4A then
					event.unregisterbyname(room_callback_name)

					active_callback = callback_name

					-- Then check for the pose of getting sucked up by the ship
					event.on_bus_write(function (addr, val, flags) 
						if val == 0x20 then
							pipe_write("split")
							event.unregisterbyname(callback_name)
						end
					end, SAMUS_POSE_ADDR + IWRAM_ADDR_OFFSET, callback_name)
				end
			end, FOREGROUND_PROPERTIES_ADDR + IWRAM_ADDR_OFFSET, room_callback_name)
		end
	else
		error("Unknown operand: " .. operand)
	end
end

local function recover_status()
	pipe_write("getsplitindex")
	local livesplit_status = tonumber(pipe_read())

	-- We're past the start point
	current_split_index = 1

	if livesplit_status == -1 then
		pipe_write("starttimer")
		-- To not have to requery it for the upcoming math.
		livesplit_status = 0
	end

	while check_split_by_memory(splits[current_split_index + 1]) do
		current_split_index = current_split_index + 1
	end

	if (current_split_index == livesplit_status) then
		return
	end

	local skips = current_split_index - livesplit_status - 1

	if skips < 0 then
		while skips < 0 do
			pipe_write("unsplit")
			skips = skips + 1
		end
	else
		while skips > 0 do
			pipe_write("skipsplit")
			skips = skips - 1
		end
	end

	arm_split(splits[current_split_index + 1])
end


local function init_livesplit()
    pipe_handle = io.open("//./pipe/LiveSplit", 'a+')

    if not pipe_handle then
        error("\nFailed to open LiveSplit named pipe!\n" ..
              "Please make sure LiveSplit is running and is at least 1.7, " ..
              "then load this script again")
    end

	local game_mode = mainmemory.readbyte(GAMEMODE_ADDR)

	if (game_mode == 0x0 or game_mode == 0x7) then
		pipe_write("reset")
		arm_split(splits[current_split_index + 1])
    elseif (game_mode ~= 0x4A) then 
		print("Fusion 100% Autosplitter Started Mid-Game, Recovering at best ability... \n")
		recover_status()
	end
	
    return pipe_handle
end

console.clear()
pipe_handle = init_livesplit()

local function load_state()
	if active_callback then
		event.unregisterbyname(active_callback)
	end
	
	print("Load State Detected, recovering status...\n")
	recover_status()
end

event.onloadstate(load_state)

-- Required to keep events firing.
while true do
	emu.frameadvance();
end
