local FILE_NAME <const> = "C:\\Users\\Public\\Documents\\MetroidFusion_RoomTimer.txt"

local ROOM_ID_ADDR <const> = 0x0033;
local IWRAM_ADDR_OFFSET <const> = 0x03000000;

local rooms = {
	[0]="Docking Bays",
	[3]="Docking Bays Entrance",
	[6]="Docking Bays Access Shaft",
	[7]="Main Deck Entrance",
	[8]="Main Deck Recharge",
	[9]="Main Deck North Navigation",
	[10]="East Wing Lobby B",
	[12]="East Wing Lobby A",
	[13]="Operations Deck",
	[14]="East Deck Ventilation",
	[16]="Main Deck South Navigation",
	[18]="West Wing Stairwell",
	[20]="Stairwell to Research",
	[21]="East Wing Stairwell",
	[23]="Quarantine Checkpoint",
	[32]="Operations Deck Navigation",
	[33]="Main Deck Save",
	[35]="Operations Deck Ventilation Shaft",
	[36]="East Wing Lobby Bridge",
	[37]="East Wing Save",
	[38]="Arachnus' Chamber",
	[39]="Operations Deck Data",
	[44]="Operations Deck Save",
	[45]="Operations Deck Ventilation Item West",
	[60]="Transport to Main Deck",
	[61]="Transport to Operations Deck",
	[70]="Main Deck Save Room Access",
	[71]="Quarantine Bay",
	[74]="Operations Deck Spooky",
	[81]="Operations Deck Recharge",
	[84]="Operations Deck Ventilation Item East",
}

local current_room = -1;
local entry_time = 0;
local frames = 0;
local room_file = io.open(FILE_NAME, "a")

local function write_to_file(data)
	room_file:write(data)
	room_file:flush()
end

if room_file then
	local current_time = os.date("%Y-%m-%d %H:%M:%S")
	write_to_file(string.format("\n\n\nMetroid Fusion (J): %s \n\n\n", current_time))
else
	print("Error opening file for writing: " .. FILE_NAME)
end

local function room_id_to_string(id)
	if rooms[id] then
		return rooms[id]
	else
		return "Unknown Room (" .. id .. ")"
	end
end

event.on_bus_write(function (addr, val, flags)
	if current_room == val then
		return
	end

	if entry_time ~= 0 then
		local time_spent = os.clock() - entry_time
		write_to_file(string.format("%s\n%.2fs %df\n", room_id_to_string(current_room), time_spent, frames))
	end

	current_room = val
	frames = 0
	entry_time = os.clock()
end, ROOM_ID_ADDR + IWRAM_ADDR_OFFSET, "fusion-roomtimer")


while true do
	frames = frames + 1
	emu.frameadvance();
end
