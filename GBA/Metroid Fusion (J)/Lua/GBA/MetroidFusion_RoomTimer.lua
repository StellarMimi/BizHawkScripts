local FILE_NAME <const> = "C:\\Users\\Public\\Documents\\MetroidFusion_RoomTimer.txt"

local REGION_ID_ADDR <const> = 0x0032;
local ROOM_ID_ADDR <const> = 0x0033;
local IWRAM_ADDR_OFFSET <const> = 0x03000000;

local rooms = {
	[0]={
		[0]="Docking Bays",
		[3]="Docking Bays Entrance",
		[6]="Docking Bays Access Shaft",
		[7]="Main Deck Entrance",
		[8]="Main Deck Recharge",
		[9]="Main Deck North Navigation",
		[10]="East Wing Lobby B",
		[11]="Habitation Deck Save",
		[12]="East Wing Lobby A",
		[13]="Operations Deck",
		[14]="East Deck Ventilation",
		[15]="Habitation Deck Overlook",
		[16]="Main Deck South Navigation",
		[18]="West Wing Stairwell",
		[20]="Stairwell to Research",
		[21]="East Wing Stairwell",
		[22]="Habitation Deck Ventilation",
		[23]="Quarantine Checkpoint",
		[24]="Sector Lobby",
		[25]="Transport to Sector 2",
		[26]="Transport to Sector 4",
		[27]="Transport to Sector 6",
		[28]="Transport to Sector 1",
		[29]="Transport to Sector 3",
		[30]="Transport to Sector 5",
		[32]="Operations Deck Navigation",
		[33]="Main Deck Save",
		[34]="Main Elevator Middle",
		[35]="Operations Deck Ventilation Shaft",
		[36]="East Wing Lobby Bridge",
		[37]="East Wing Save",
		[38]="Arachnus' Chamber",
		[39]="Operations Deck Data",
		[40]="Transport to Sector Lobby",
		[42]="Access to Main Elevator",
		[44]="Operations Deck Save",
		[45]="Operations Deck Ventilation Item West",
		[46]="Sub-Zero Containment",
		[47]="Elevator Maintenance East",
		[57]="Main Deck PB Room",
		[60]="Transport from Operations Deck",
		[61]="Transport to Operations Deck",
		[69]="Habitation Deck",
		[70]="Main Deck Save Room Access",
		[71]="Quarantine Bay",
		[72]="Main Deck Morph Missles",
		[73]="Main Elevator Missles",
		[74]="Operations Deck Spooky",
		[75]="Transport to Habitation Deck",
		[76]="Transport from Habitation Deck",
		[81]="Operations Deck Recharge",
		[84]="Operations Deck Ventilation Item East",
	},
	[1] = {
		[41]="Transport from Sector 1",
		[2]="Sector 1 Navigation",
		[1]="Sector 1 Save",
		[11]="Sector 1 Recharge",
		[0]="Sector 1 Main Hall",
		[3]="SRX Entrance Hall",
		[4]="Environmental Cavern 1",
		[5]="Environmental Hall",
		[6]="Junction Shaft",
		[7]="Rocky Road",
		[8]="West Maintenance Shaft",
		[12]="Cavern Junction East",
		[13]="Environmental Cavern 3",
		[15]="Environmental Cavern 4",
		[17]="Magma Cavern",
		[16]="Serviceway",
		[20]="Western Cave",
		[32]="Environmental Cavern 2",
		[33]="Junction Divide",
		[35]="East Maintenance Shaft",
		[37]="Tall Access Shaft",
		[38]="Flooded Cavern",
		[42]="Sector 1 Center Save",
		[44]="Cavern Cache A",
		[45]="Cavern Junction West",
		[46]="Cavern Farm",
		[47]="Flooded Shaft",

	}
}

local current_room = -1;
local current_region = -1;
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

local function room_id_to_string(region, id)
	if rooms[region][id] then
		return rooms[region][id]
	else
		return "Unknown Room (".. region .. ":" .. id .. ")"
	end
end

event.on_bus_write(function (addr, val, flags)
	if current_room == val then
		return
	end

	if entry_time ~= 0 then
		local time_spent = os.clock() - entry_time
		write_to_file(string.format("%s\n%.2fs %df\n", room_id_to_string(current_region, current_room), time_spent, frames))
	end

	current_room = val
	current_region = mainmemory.readbyte(REGION_ID_ADDR)
	frames = 0
	entry_time = os.clock()
end, ROOM_ID_ADDR + IWRAM_ADDR_OFFSET, "fusion-roomtimer")


while true do
	frames = frames + 1
	emu.frameadvance();
end
