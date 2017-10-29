-- chat3/init.lua

chat3 = {}

chat3.settings = {}
chat3.storage = minetest.get_mod_storage()

local modpath = minetest.get_modpath("chat3")

local prot = {} -- Table of protocol versions - to be used later

---
--- Handle Settings
---

-- [function] Get float setting
function chat3.settings.get_int(key)
	local res = minetest.settings:get(key)
	if res then
		return tonumber(res)
	end
end

-- [function] Get boolean setting
function chat3.settings.get_bool(key, default)
	local retval = minetest.settings:get_bool(key)

	if default and retval == nil then
		retval = default
	end

	return retval
end

local bell   = chat3.settings.get_bool("chat3.bell")
local shout  = chat3.settings.get_bool("chat3.shout")
local prefix = minetest.settings:get("chat3.shout_prefix") or "!"
local near   = chat3.settings.get_int("chat3.near") or 12
local ignore = chat3.settings.get_bool("chat3.ignore", true)
local alt    = chat3.settings.get_bool("chat3.alt_support", true)

if prefix:len() > 1 then
	prefix = "!"
end

---
--- Load Features
---

if ignore then dofile(modpath.."/ignore.lua") end -- Load ignore
if alt then dofile(modpath.."/alt.lua") end -- Load alt

---
--- Exposed Functions (API)
---

-- [function] Colorize
function chat3.colorize(name, colour, msg)
	local vers = prot[name]
	if vers and vers >= 27 then
		return minetest.colorize(colour, msg)
	else
		return msg
	end
end

-- [function] Check if mentioned (should highlight or not)
function chat3.is_mentioned(name, msg)
	name, msg = name:lower(), msg:lower()

	-- Direct mentions
	local direct_mention = msg:find(name, 1, true)

	-- Alt mentions
	local alt_mention
	if alt then
		local list = chat3.alt.get(name)
		for alt, i in pairs(list) do
			alt_mention = msg:find(alt, 1, true) or alt_mention
		end
	end

	return direct_mention or alt_mention
end

-- [function] Process
function chat3.send(name, msg, prefix, source)
	if minetest.get_modpath("ranks") and source ~= "ranks" then
		return
	end

	local sender = minetest.get_player_by_name(name)

	for _, player in pairs(minetest.get_connected_players()) do
		local rname  = player:get_player_name()
		local colour = "#ffffff"

		local vers = prot[rname]
		if (not vers or (vers and (vers >= 29 or (vers < 29 and name ~= rname))))
				and (not ignore or not chat3.ignore.is(rname, name)) then
			-- Check for near
			if near ~= 0 then -- and name ~= rname then
				if vector.distance(sender:getpos(), player:getpos()) <= near then
					colour = "#88ffff"
				end
			end

			-- Check for mentions
			if chat3.is_mentioned(rname, msg) then
				colour = "#00ff00"

				-- Chat bell
				if bell and name ~= rname then
					local pbell = player:get_attribute("chat3:bell")
					if pbell ~= "false" then
						minetest.sound_play("chat3_bell", {
							gain = 4,
							to_player = rname,
						})
					end
				end
			end

			-- Check for shout
			if shout and msg:sub(1, 1) == prefix then
				colour = "#ff0000"

				-- Chat bell
				if bell and name ~= rname then
					local pbell = player:get_attribute("chat3:bell")
					if pbell ~= "false" then
						minetest.sound_play("chat3_bell", {
							gain = 4,
							to_player = rname,
						})
					end
				end
			end

			-- if same player, set to white
			if name == rname then
				colour = "#ffffff"
			end

			-- Send message
			local send = chat3.colorize(rname, colour, "<"..name.."> "..msg)
			if prefix then
				send = prefix..send
			end

			minetest.chat_send_player(rname, send)
		end
	end

	-- Log message
	minetest.log("action", "CHAT: ".."<"..name.."> "..msg)

	-- Prevent from sending normally
	return true
end

---
--- Events/Definitions
---

-- [event] On join player
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local info = minetest.get_player_information(name)
	prot[name] = info.protocol_version
end)

-- [event] On chat message
minetest.register_on_chat_message(function(name, msg)
	return chat3.send(name, msg)
end)

-- [redefine] /msg
if minetest.chatcommands["msg"] then
	local old_command = minetest.chatcommands["msg"].func
	minetest.override_chatcommand("msg", {
		func = function(name, param)
			local sendto, message = param:match("^(%S+)%s(.+)$")
			if not sendto then
				return false, "Invalid usage, see /help msg."
			end
			if not minetest.get_player_by_name(sendto) then
				return false, "The player " .. sendto
						.. " is not online."
			end

			if ignore and chat3.ignore.is(sendto, name) then
				return false, chat3.colorize(name, "red",
						"Could not send message, you are on "..sendto.."'s ignore list.")
			else

				minetest.log("action", "PM from " .. name .. " to " .. sendto
						.. ": " .. message)
				minetest.chat_send_player(sendto, chat3.colorize(sendto, '#00ff00',
						"PM from " .. name .. ": ".. message))

				if bell then
					local player = minetest.get_player_by_name(sendto)
					local pbell = player:get_attribute("chat3:bell")
					if pbell ~= "false" then
						minetest.sound_play("chat3_bell", {
							gain = 4,
							to_player = sendto,
						})
					end
				end

				if ignore and chat3.ignore.is(name, sendto) then
					return true, "Message sent.\n"..chat3.colorize(name, "red",
							"Warning: "..sendto.." will not be able to respond to this"
							.." message unless you remove them from your ignore list.")
				else
					return true, "Message sent."
				end
			end
		end,
	})
end

-- [redefine] /me
if minetest.chatcommands["me"] then
	local old_command = minetest.chatcommands["me"]
	minetest.override_chatcommand("me", {
		func = function(name, param)
			for _, player in pairs(minetest.get_connected_players()) do
				local rname = player:get_player_name()

				if not ignore or not chat3.ignore.is(rname, name) then
					minetest.chat_send_player(rname, "* "..name.." "..param)
				end
			end
		end,
	})
end

-- [chatcommand] Chatbell
if bell then
	minetest.register_chatcommand("chatbell", {
		description = "Enable/disable chatbell when you are mentioned in the chat",
		func = function(name)
			local player = minetest.get_player_by_name(name)
			if player then
				local bell = player:get_attribute("chat3:bell")
				if not bell or bell == "" or bell == "true" then
					player:set_attribute("chat3:bell", "false")
					return true, "Disabled Chatbell"
				else
					player:set_attribute("chat3:bell", "true")
					return true, "Enabled Chatbell"
				end
			end
		end,
	})
end
