-- chat3/init.lua

local near = minetest.setting_get("chat3.highlight_near") or 12

-- [event] On chat message
minetest.register_on_chat_message(function(name, msg)
  local sender = minetest.get_player_by_name(name)

  for _, player in pairs(minetest.get_connected_players()) do
    local rname  = player:get_player_name()
    local colour = "#ffffff"

    -- if same player, send default
    if name == rname then
      return false
    end

    -- Check for near
    if near ~= 0 then -- and name ~= rname then
      if vector.distance(sender:getpos(), player:getpos()) <= near then
        colour = "#88ffff"
      end
    end

    -- Check for mentions
    if msg:lower():find(rname:lower(), 1, true) then
      colour = "#00ff00"
    end

    -- Send message
    minetest.chat_send_player(rname, minetest.colorize(colour, "<"..name.."> "..msg))
  end

  -- Prevent from sending normally
  return true
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
		if not core.get_player_by_name(sendto) then
			return false, "The player " .. sendto
					.. " is not online."
		end
		minetest.log("action", "PM from " .. name .. " to " .. sendto
				.. ": " .. message)
		minetest.chat_send_player(sendto, minetest.colorize('#00ff00', "PM from " .. name .. ": "
				.. message))
		return true, "Message sent."
    end,
  })
end
