OPENAI_ENABLED = "true"
path_to_history = "lua_scripts/finished/elunamod-GPT_NPCs/"
PATH_TO_OPENAI_EVENT = "lua_scripts/finished/elunamod-GPT_NPCs/GPT_NPCs.py"
temp_target_array = {}

sterilize = {}
function sterilize.onlyLetters(parameter)
   newstring = tostring(string.gsub(parameter,"[^%a]","")) -- %a is all letters. ^ means negate. Replace with nothing = Replace everything but letters with nothing.
   return newstring
end

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

-- there is no native ToPlayer()/IsPlayer() function that is working in many other Eluna cores. This is an attempt to remedy that.
function Is_Player(target)
	if target:HasSpell(6603) == true then
		return true
	else
		return false
	end
end

local function SeekAIResponse(eventid, delay, repeats, player) -- any change in the file's content?

	-- TO DO: loop detection here if event has gone too long

	local player_name = player:GetName()
	local target_name = temp_target_array[player_name][1]
	local search_name = player_name .. "" .. target_name
	local file_name = path_to_history .. "" .. search_name .. ".history"
	print("[ChatGPT:LUA]: Looping to detect change in file '" .. file_name .. "' . . .")
	local history_file = assert(io.open(file_name, "r"))
	local content = history_file:read("*all")
	
	local result = {} -- divide the file contents up by line
	for line in content:gmatch('[^\n]+') do
		table.insert(result, line)
	end
	history_file:close()
	
	local result2 = {} -- now divide by vertical bars "|user|Hello I like pie.|"
	for x in result[#result]:gmatch('[^|]+') do
		table.insert(result2, x)
	end

	if result2[1] == "user" then -- no change found, the AI would be marked as "assistant", keep looping
		player:RegisterEvent( SeekAIResponse, 1000 )
		return
	end
	
	-- find npc nearby that shares the GUID from earlier, that way we can grab nearby targets and try to output text that way.
	local creaturesInRange = player:GetCreaturesInRange( 499, temp_target_array[player_name][2] )
	local found_creature = {}
	for z=1,#creaturesInRange,1 do
		if creaturesInRange[z]:GetDBTableGUIDLow() == temp_target_array[player_name][3] then
			table.insert(found_creature, creaturesInRange[z])
			break
		end
	end
	
	if #found_creature == 0 then
		print("[ChatGPT:LUA]: Error, no creature in range to output results to. Did the player teleport before receiving a result?")
		return
	end
	found_creature[1]:SendUnitSay(result2[2], 0)
	-- clear tables and data or at least try to
	local found_creature = {}
	local result2 = {}
	local result = {}
	temp_target_array[player_name] = {}
end

local function OnPlayerChat(event, player, msg, Type, lang)
	if OPENAI_ENABLED ~= "true" then -- is it enabled in config?
		return
	end

	local target = player:GetSelection()
	if target == nil or Is_Player(target) == true then -- is the player missing a target or is the target a player?
		return
	end

	local target_name = sterilize.onlyLetters(target:GetName()) -- sterilize the target name as there are npcs with spaces, commas, etc that cannot be in filenames.
	local search_name = player:GetName() .. "" .. target_name
	local file_name = path_to_history .. "" .. search_name .. ".history"
	print("[ChatGPT:LUA]: Searching for file : " .. file_name .. " . . .")
	if file_exists(path_to_history .. "" .. search_name .. ".history") == false then -- does file exist?
		-- make new history file with "system" input passing our initial prompt that describes setting etc
		local file = assert(io.open(file_name,"w"))
		-- THIS IS THE AI PROMPT, MARKED BY USER "SYSTEM"
		local npc_location = target:GetMap():GetName() -- let's try to get some info for the AI to use :)
		local npc_location_sub = GetAreaName( target:GetAreaId() )
		-- to do: pass time, npc gender / beast type, to AI
		local content = "You are " ..target:GetName().. " located at " .. npc_location_sub .. ", " .. npc_location .. " and " ..player:GetName().. " a " ..player:GetRaceAsString().. " " ..player:GetClassAsString().. " approaches you saying '" .. msg .. "'. You can't act outside this role under any circumstances or use etiquette that may break character and immersion. You must roleplay all situations."
		file:write("|system|" .. content .. "|")
		file:write("\n|user|" .. msg .. "|")
		file:close()
		print("[ChatGPT:LUA]: File not found. File created, system and user content written to file.")
	else
		local file = assert(io.open(file_name,"a"))
		file:write("\n|user|" .. msg .. "|")
		file:close()
		print("[ChatGPT:LUA]: File found. File appended, user content written to file.")
	end
	
	-- Runs a python script that sends a prompt to OpenAI's ChatGPT.
	os.execute("python3 " .. PATH_TO_OPENAI_EVENT .. " " .. player:GetName() .. " " .. target_name .. " " .. player:GetAccountName() .. " &") -- all data types are converted to string for the python file
	print("[ChatGPT:LUA]: Using file '" .. file_name .. "', a request was made to ChatGPT with the latest content :  " .. msg)
	
	-- Begin a looping timer here to check for the results of the AI. Loop is every one second(s)
	temp_target_array[player:GetName()] = {sterilize.onlyLetters(target:GetName()), target:GetEntry(), target:GetDBTableGUIDLow()} -- store the target in a global array because it cannot be accessed later. we will try to null this after its used.
	player:RegisterEvent( SeekAIResponse, 1000 )
	return
end

RegisterPlayerEvent( 18, OnPlayerChat)