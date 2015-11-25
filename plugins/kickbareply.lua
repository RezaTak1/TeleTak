[Forwarded from plugins]
local function get_message_callback(extra, success, result)

  if result.to.type == 'chat' then
    if our_id == result.from.id then
      send_msg(extra, "Nice try.", ok_cb, false)
    else
      local del = chat_del_user("chat#id"..result.to.id, "user#id"..result.from.id, ok_cb, false)
      if del == false then
        send_msg(extra, "Kicking failed.", ok_cb, false)
        return
      end
    end
  else
    send_msg(extra, "You're not in a group", ok_cb, false)
    return
  end
end

local function run(msg, matches)
  if is_mod(msg) then
    if msg.text == "!kick" and msg.reply_id then
      msgr = get_message(msg.reply_id,get_message_callback, get_receiver(msg))
    end
  end
end

return {
  description = "Kick by Reply",
  usage = {
    "!kick"
  },
  patterns = {
    "^!kick$"
  },
  run = run,
  hide = true
}
