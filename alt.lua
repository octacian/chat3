-- chat3/alt.lua

chat3.alt = {}

local storage = chat3.storage
local MAX = chat3.settings.get_int("chat3.alt_max") or 3

---
--- Functions (exposed API)
---

-- [function] Get alt list
function chat3.alt.get(name)
	local list = storage:get_string("alt_list_"..name)

	if list then
		list = minetest.deserialize(list)
	end

	return list or {}
end

-- [function] Set alt list
function chat3.alt.set(name, list)
	storage:set_string("alt_list_"..name, minetest.serialize(list))
end

-- [function] Add alt
function chat3.alt.add(name, alt)
	local list = chat3.alt.get(name)

	local count = 0
	for _, i in pairs(list) do
		count = count + 1
	end

	if count < MAX and not list[alt] then
		list[alt] = true
		chat3.alt.set(name, list)
	else
		return
	end

	return true
end

-- [function] Remove alt
function chat3.alt.remove(name, alt)
	local list = chat3.alt.get(name)

	if list[alt] then
		list[alt] = nil
	else
		return
	end

	chat3.alt.set(name, list)
	return true
end

-- [function] List Alt Usernames (returns a table suitable for use with table.concat)
function chat3.alt.list(name)
	local list, result = chat3.alt.get(name), {}
	if list then
		for alt, i in pairs(list) do
			table.insert(result, alt)
		end

		if #result > 0 then
			return result
		end
	end
end

---
--- Registrations
---

-- [chatcommand] Alt
minetest.register_chatcommand("alt", {
	description = "Manage your chat3 alternate usernames",
	params = "[list | add | del | rst] [<alternate username>]",
	func = function(name, params)
		params = params:split(" ")
		local operation, alt = params[1], params[2]

		if operation == "list" then
			local list = chat3.alt.list(name)
			if list then
				return true, "Your Alternate Usernames: "..table.concat(list, ", ")
			else
				return false, "You have not yet configured any alternate usernames."
			end
		elseif operation == "add" and alt and alt ~= "" then
			if chat3.alt.add(name, alt) then
				return true, "Added alternate username \""..alt.."\"."
			else
				return false, "You have either reached the max number ("..tostring(MAX)
						..") of alternate usernames, or the alternate username already exists."
			end
		elseif operation == "del" and alt and alt ~= "" then
			if chat3.alt.remove(name, alt) then
				return true, "Removed alternate username \""..alt.."\"."
			else
				return false, "Alternate username already does not exist."
			end
		elseif operation == "rst" then
			chat3.alt.set(name, {})
			return true, "Reset your alternate username list."
		else
			return false, "Invalid parameters (see /help alt)"
		end
	end,
})
