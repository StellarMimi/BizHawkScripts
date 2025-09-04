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
		[19]="Transport to Sector Lobby",
		[20]="Stairwell to Research",
		[21]="East Wing Stairwell",
		[22]="Habitation Deck Ventilation",
		[23]="Quarantine Checkpoint",
		[24]="Sector Lobby",
		[25]="Transport to TRO",
		[26]="Transport to AQA",
		[27]="Transport to NOC",
		[28]="Transport to SRX",
		[29]="Transport to PYR",
		[30]="Transport to ARC",
		[32]="Operations Deck Navigation",
		[33]="Main Deck Save",
		[34]="Main Elevator Middle",
		[35]="Operations Deck Ventilation Shaft",
		[36]="East Wing Lobby Bridge",
		[37]="East Wing Save",
		[38]="Arachnus' Chamber",
		[39]="Operations Deck Data",
		[40]="Transport to Sector Lobby",
		[41]="Access to Main Elevator",
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
		[0]="SRX Main Hall",
		[1]="SRX Save",
		[2]="SRX Navigation",
		[3]="SRX Entrance Hall",
		[4]="Environmental Cavern 1",
		[5]="Environmental Hall",
		[6]="Junction Divide",
		[7]="Rocky Road",
		[8]="West Maintenance Shaft",
		[9]="Environmental Cavern 5",
		[10]="Escape Roof",
		[11]="SRX Recharge",
		[12]="Cavern Junction East",
		[13]="Environmental Cavern 3",
		[14]="Junction Divide",
		[15]="Environmental Cavern 4",
		[17]="Magma Cavern",
		[16]="Serviceway",
		[20]="Western Cave",
		[32]="Environmental Cavern 2",
		[33]="Junction Shaft",
		[34]="SRX East Save",
		[35]="East Maintenance Shaft",
		[37]="Tall Access Shaft",
		[38]="Flooded Cavern",
		[40]="Chozo Research",
		[41]="Transport from SRX",
		[42]="SRX Center Save",
		[44]="Cavern Cache A",
		[45]="Cavern Junction West",
		[46]="Cavern Farm",
		[47]="Flooded Shaft",
		[50]="Hidden Save Cache",
	},
	[2] = {
		[0]="TRO Main Hall",
		[1]="TRO Save",
		[2]="TRO Navigation",
		[3]="Northeast Research Hall",
		[4]="West Research Hall",
		[5]="TRO Security Station",
		-- Pre SA-X
		[7]="Transit Plaza",
		[8]="TRO Data Room",
		[9]="Botonical Maze",
		[10]="Jungle Chamber",
		[11]="West Passage",
		[13]="Central Shaft",
		[26]="Level 1 Security Room",
		[29]="Transport from TRO",
		-- Post SA-X
		[31]="Transit Plaza",
		[37]="TRO Recharge",
		[43]="Transfer Shaft",

	},
	[3] = {
	},
	[4] = {
	},
	[5] = {
	},
	[6] = {
	},
	[7] = {
	},
	[8] = {
	},
	[9] = {
	},
	[10] = {
	},

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
