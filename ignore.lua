-- chat3/ignore.lua

chat3.ignore = {}

local storage = chat3.storage

---
--- Functions (API)
---

-- [function] Get ignore list
function chat3.ignore.get(name)
	local list = storage:get_string("ignore_list_"..name)

	if list then
		list = minetest.deserialize(list)
	end

	if not list or not list.ignoring or not list.ignored_by then
		list = {ignoring = {}, ignored_by = {}}
	end

	return list
end

-- [function] Set ignore list
function chat3.ignore.set(name, list)
	storage:set_string("ignore_list_"..name, minetest.serialize(list))
end

-- [function] Add name to list
function chat3.ignore.add_name(name, ignore)
	-- Update ignoring
	local list = chat3.ignore.get(name)
	list.ignoring[ignore] = true
	chat3.ignore.set(name, list)

	-- Update ignored_by
	list = chat3.ignore.get(ignore)
	list.ignored_by[name] = true
	chat3.ignore.set(ignore, list)

	return true
end

-- [function] Remove name from list
function chat3.ignore.remove_name(name, unignore)
	-- Update ignoring
	local list = chat3.ignore.get(name)
	list.ignoring[unignore] = nil
	chat3.ignore.set(name, list)

	-- Update ignored_by
	list = chat3.ignore.get(unignore)
	list.ignored_by[name] = nil
	chat3.ignore.set(unignore, list)

	return true
end

-- [function] Clear ignore list
function chat3.ignore.clear(name)
	local list = chat3.ignore.get(name)

	-- Clear resulting ignored_by entries and notify
	for t, i in pairs(list.ignoring) do
		local tlist = chat3.ignore.get(t)
		tlist.ignored_by[name] = nil
		chat3.ignore.set(t, tlist)
		minetest.chat_send_player(t, chat3.colorize(t, "#00ff00", name..
				" is no longer ignoring you."))
		list.ignoring[t] = nil
	end

	chat3.ignore.set(name, list)

	return true
end

-- [function] Can ignore
function chat3.ignore.can(name, check)
	local priv = minetest.check_player_privs(check, "ignore_override")
	if not priv and minetest.settings:get("name") ~= check and name ~= check then
		return true
	else
		chat3.ignore.remove_name(name, check)
	end
end

-- [function] Is Ignoring
function chat3.ignore.is(name, check)
	if name == check then
		return false
	else
		local list = chat3.ignore.get(check).ignored_by
		return list[name] and chat3.ignore.can(name, check)
	end
end

-- [function] Ignore
function chat3.ignore.add(name, ignore)
	if chat3.ignore.can(name, ignore) then
		if chat3.ignore.get(name).ignoring[ignore] then
			return false, "You are already ignoring "..ignore.."."
		else
			chat3.ignore.add_name(name, ignore)

			-- Notify ignored player
			if minetest.get_player_by_name(ignore) then
				minetest.chat_send_player(ignore, chat3.colorize(ignore, "red", name..
						" is now ignoring you."))
			end

			return true, "Added "..ignore.." to your ignore list."
		end
	else
		return false, "You cannot ignore "..ignore.."."
	end
end

-- [function] Unignore
function chat3.ignore.remove(name, unignore)
	if chat3.ignore.get(name).ignoring[unignore] then
		chat3.ignore.remove_name(name, unignore)

		-- Notify unignored player
		if minetest.get_player_by_name(unignore) then
			minetest.chat_send_player(unignore, chat3.colorize(unignore, "#00ff00",
					name.." is no longer ignoring you."))
		end

		return true, "Removed "..unignore.." from your ignore list."
	else
		return false, unignore.." is already not on your ignore list."
	end
end

-- [function] Check Ignore (verbose [chat] version if Is Ignoring)
function chat3.ignore.check(name, check)
	minetest.log("chat3.ignore.check: "..name..", "..check)
	if chat3.ignore.is(name, check) then
		return true, "You are being ignored by "..name.."."
	else
		return false, name.." is not ignoring you."
	end
end

-- [function] List Ignored Players (returns a table suitable for use with table.concat)
function chat3.ignore.list(name, subtable)
	local list, result = chat3.ignore.get(name)[subtable], {}
	if list then
		for ignored, i in pairs(list) do
			table.insert(result, ignored)
		end

		if #result > 0 then
			return result
		end
	end
end

---
--- Registrations
---

-- [event] Show list of people ignoring you on join
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local list = chat3.ignore.list(name, "ignored_by")
	if list then
		local p = "players"
		if #list == 1 then
			p = "player"
		end

		minetest.chat_send_player(name, string.format(
				"You are being ignored by %i %s: %s.", #list, p,
				table.concat(list, ", ")))
	end
end)

-- [privilege] Ignore Override
minetest.register_privilege("ignore_override", {
	description = "Prevent players from ignoring anyone with this privilege.",
	give_to_singleplayer = false,
})

-- [chatcommand] Ignore
minetest.register_chatcommand("ignore", {
	description = "Ignore players",
	params = "[list | by | add | del | rst | check] [<player username>]",
	func = function(name, params)
		params = params:split(" ")
		local operation, target = params[1], params[2]
		local invalid = "Invalid parameters (see /help ignore)"

		if operation and operation ~= "" then
			if operation == "list" then
				local list = chat3.ignore.list(name, "ignoring")
				if list then
					return true, "Ignored Players: "..table.concat(list, ", ").."."
				else
					return false, "You are not ignoring any players."
				end
			elseif operation == "by" then
				local list = chat3.ignore.list(name, "ignored_by")
				if list then
					return true, "You are being ignored by: "..table.concat(list, ", ").."."
				else
					return false, "You are not being ignored by any players."
				end
			elseif operation == "add" and target and target ~= "" then
				return chat3.ignore.add(name, target)
			elseif operation == "del" and target and target ~= "" then
				return chat3.ignore.remove(name, target)
			elseif operation == "check" and target and target ~= "" then
				return chat3.ignore.check(target, name)
			elseif operation == "rst" then
				chat3.ignore.clear(name)
				return true, "Cleared your ignore list."
			else
				return false, invalid
			end
		else
			return false, invalid
		end
	end,
})
