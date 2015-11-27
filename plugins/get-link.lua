do
--developed by @i9Dev
local function create_group(msg)
  -- superuser and admins only (because sudo are always has privilege)
  if not is_admin(msg) then
    return "Você não é um Administrador."
  end
  local group_creator = msg.from.print_name
  create_group_chat (group_creator, group_name, ok_cb, false)
  return 'O grupo '..string.gsub(group_name, '_', ' ')..' foi criado.'
end
--developed by @i9Dev
local function set_description(msg, data)
  if not is_mod(msg) then
    return "Apenas moderadores."
  end
  local data_cat = 'description'
	data[tostring(msg.to.id)][data_cat] = deskripsi
	save_data(_config.moderation.data, data)
  return 'Descrição do grupo criada:\n\n'..deskripsi
end
--developed by @i9Dev
local function get_description(msg, data)
  local data_cat = 'description'
  if not data[tostring(msg.to.id)][data_cat] then
    return 'O grupo não tem uma descrição.'
	end
  local about = data[tostring(msg.to.id)][data_cat]
  local about = string.gsub(msg.to.print_name, "_", " ")..':\n\n'..about
  return 'Sobre o '..about
end
--developed by @i9Dev
local function export_chat_link_callback(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local chat_id = cb_extra.chat_id
  local group_name = cb_extra.group_name
  if success == 0 then
    return send_large_msg(receiver, "Não é possível gerar link para este grupo.")
  end
  data[tostring(chat_id)]['link'] = result
  save_data(_config.moderation.data, data)
  return send_large_msg(receiver,result)
end
--developed by @i9Dev
local function set_rules(msg, data)
  vardump(data)
  vardump(msg)
  if not is_mod(msg) then
    return "Apenas moderadores."
  end
  local data_cat = 'rules'
	data[tostring(msg.to.id)][data_cat] = rules
	save_data(_config.moderation.data, data)
  return 'Regras do grupo criada:\n\n'..rules
end

local function get_rules(msg, data)
  local data_cat = 'rules'
  if not data[tostring(msg.to.id)][data_cat] then
    return 'O grupo não tem regras.'
	end
  local rules = data[tostring(msg.to.id)][data_cat]
  local rules = string.gsub(msg.to.print_name, '_', ' ')..' Regras:\n\n'..rules
  return rules
end

-- lock/unlock group name. bot automatically change group name when locked
local function lock_group_name(msg, data)
  if not is_mod(msg) then
    return "Apenas moderadores."
  end
  local group_name_set = data[tostring(msg.to.id)]['settings']['set_name']
  local group_name_lock = data[tostring(msg.to.id)]['settings']['lock_name']
	if group_name_lock == 'Sim' then
    return 'O nome do grupo já está bloqueado.'
	else
	  data[tostring(msg.to.id)]['settings']['lock_name'] = 'Sim'
	  save_data(_config.moderation.data, data)
	  data[tostring(msg.to.id)]['settings']['set_name'] = string.gsub(msg.to.print_name, '_', ' ')
	  save_data(_config.moderation.data, data)
    return 'O nome do grupo foi bloqueado.'
	end
end

local function unlock_group_name(msg, data)
  if not is_mod(msg) then
    return "Apenas moderadores."
  end
  local group_name_set = data[tostring(msg.to.id)]['settings']['set_name']
  local group_name_lock = data[tostring(msg.to.id)]['settings']['lock_name']
	if group_name_lock == 'Nao' then
    return 'O nome do grupo já está desbloqueado.'
	else
	  data[tostring(msg.to.id)]['settings']['lock_name'] = 'Nao'
	  save_data(_config.moderation.data, data)
    return 'O nome do grupo foi desbloqueado.'
	end
end

--lock/unlock group member. bot automatically kick new added user when locked
local function lock_group_member(msg, data)
  if not is_mod(msg) then
    return "Apenas moderadores."
  end
  local group_member_lock = data[tostring(msg.to.id)]['settings']['lock_member']
	if group_member_lock == 'Sim' then
    return 'Os membros do grupo já estão bloqueados.'
	else
	  data[tostring(msg.to.id)]['settings']['lock_member'] = 'Sim'
	  save_data(_config.moderation.data, data)
	end
  return 'Os membros do grupo foram bloqueados.'
end

local function unlock_group_member(msg, data)
  if not is_mod(msg) then
    return "Apenas moderadores."
  end
  local group_member_lock = data[tostring(msg.to.id)]['settings']['lock_member']
	if group_member_lock == 'Nao' then
    return 'Os membros do grupo não estão bloqueados.'
	else
	  data[tostring(msg.to.id)]['settings']['lock_member'] = 'Nao'
	  save_data(_config.moderation.data, data)
    return 'Os membros do grupo foram desbloqueado.'
	end
end

--lock/unlock group photo. bot automatically keep group photo when locked
local function lock_group_photo(msg, data)
  if not is_mod(msg) then
    return "Apenas moderadores."
  end
  local group_photo_lock = data[tostring(msg.to.id)]['settings']['lock_photo']
	if group_photo_lock == 'Sim' then
    return 'A imagem do grupo já está bloqueada.'
	else
	  data[tostring(msg.to.id)]['settings']['set_photo'] = 'waiting'
	  save_data(_config.moderation.data, data)
	end
  return 'Por favor me envie a foto do grupo.'
end

local function unlock_group_photo(msg, data)
  if not is_mod(msg) then
    return "Apenas moderadores."
  end
  local group_photo_lock = data[tostring(msg.to.id)]['settings']['lock_photo']
	if group_photo_lock == 'Nao' then
    return 'A imagem do grupo ainda não foi bloqueada.'
	else
	  data[tostring(msg.to.id)]['settings']['lock_photo'] = 'Nao'
	  save_data(_config.moderation.data, data)
    return 'A imagem do grupo foi desbloqueada.'
	end
end

local function set_group_photo(msg, success, result)
  local data = load_data(_config.moderation.data)
  local receiver = get_receiver(msg)
  if success then
    local file = 'data/photos/chat_photo_'..msg.to.id..'.jpg'
    print('Baixando imagem em:', result)
    os.rename(result, file)
    print('Movendo imagem para:', file)
    chat_set_photo (receiver, file, ok_cb, false)
    data[tostring(msg.to.id)]['settings']['set_photo'] = file
    save_data(_config.moderation.data, data)
    data[tostring(msg.to.id)]['settings']['lock_photo'] = 'Sim'
    save_data(_config.moderation.data, data)
    send_large_msg(receiver, 'Imagem salva!', ok_cb, false)
  else
    print('Erro ao baixar imagem: '..msg.id)
    send_large_msg(receiver, 'Me envie novamente', ok_cb, false)
  end
end
-- show group settings
local function show_group_settings(msg, data)
  if not is_mod(msg) then
    return "Apenas moderadores."
  end
  local settings = data[tostring(msg.to.id)]['settings']
  local text = "🔧 Configurações do grupo\n\n🔐 Bloquear nome do grupo: "..settings.lock_name.."\n🔐 Bloquear membros do grupo: "..settings.lock_member
  return text
end

--lock/unlock spam protection
local function lock_group_spam(msg, data)
  return 'Proteção Anti Flood foi habilitado'
end

local function unlock_group_spam(msg, data)
    return 'Proteção Anti Flood foi desabilitado'
end

local function pre_process(msg)
  -- media handler
  if not msg.text and msg.media then
    msg.text = '['..msg.media.type..']'
  end

  --vardump(msg)
  if msg.action and msg.action.type then
    local action = msg.action.type
    local receiver = get_receiver(msg)
    local data = load_data(_config.moderation.data)
    if data[tostring(msg.to.id)] then
      local settings = data[tostring(msg.to.id)]['settings']
      if action == 'chat_rename' then
        local group_name_set = settings.set_name
        local group_name_lock = settings.lock_name
        local to_rename = 'chat#id'..msg.to.id
        if group_name_lock == 'Sim' then
          if group_name_set ~= tostring(msg.to.print_name) then
            rename_chat(to_rename, group_name_set, ok_cb, false)
          end
        elseif group_name_lock == 'Nao' then
          return nil
        end
      end
      if action == 'chat_add_user' or action == 'chat_add_user_link' then
        if msg.action.link_issuer then
          user_id = 'user#id'..msg.from.id
        else
          user_id = 'user#id'..msg.action.user.id
        end
        local group_member_lock = settings.lock_member
        if group_member_lock == 'Sim' and msg.from.id ~= 0 then
          chat_del_user(receiver, user_id, ok_cb, true)
        end
      end
      if action == 'chat_delete_photo' then
        local group_photo_lock = settings.lock_photo
        if group_photo_lock == 'Sim' then
          chat_set_photo(receiver, settings.set_photo, ok_cb, false)
        end
      end
      if action == 'chat_change_photo' and msg.from.id ~= 0 then
        local group_photo_lock = settings.lock_photo
        if group_photo_lock == 'Sim' then
          chat_set_photo(receiver, settings.set_photo, ok_cb, false)
        end
      end
      return msg
    end
  end
	local hash = 'floodc:'..msg.from.id..':'..msg.to.id
    redis:incr(hash)
	return msg
end

function run(msg, matches)
  --vardump(msg)

  -- media handler
  if msg.media then
    if msg.media.type == 'document' then
      print('Document file')
    end
    if msg.media.type == 'photo' then
      print('Photo file')
    end
    if msg.media.type == 'video' then
      print('Video file')
    end
    if msg.media.type == 'audio' then
      print('Audio file')
    end
  end

  -- create group
  if matches[1] == 'criar' and matches[2] == 'grupo' and matches[3] then
    group_name = matches[3]
    return create_group(msg)
  end

  if not is_chat_msg(msg) then
    return "Isso não é um grupo."
	end
  local data = load_data(_config.moderation.data)
  local receiver = get_receiver(msg)
  if msg.media then
  	if msg.media.type == 'photo' and data[tostring(msg.to.id)]['settings']['set_photo'] == 'waiting' and is_chat_msg(msg) and is_mod(msg) then
  		load_photo(msg.id, set_group_photo, msg)
  	end
  end

  if data[tostring(msg.to.id)] then
		local settings = data[tostring(msg.to.id)]['settings']

    -- group {about|rules|settings}
    if matches[1] == 'config' then
        return show_group_settings(msg, data)
    end

    if matches[1] == 'regras' then
      return get_rules(msg, data)
    end

    if matches[1] == 'sobre' then
      return get_description(msg, data)
    end

    -- group link {get|revoke}
    if matches[1] == 'link' then
        if data[tostring(msg.to.id)]['link'] then
          local link = data[tostring(msg.to.id)]['link']
        return send_large_msg(receiver,link)
        else
          local chat = 'chat#id'..msg.to.id
          msgr = export_chat_link('chat#id'..msg.to.id, export_chat_link_callback, {receiver=receiver, data=data, chat_id=msg.to.id})
      end
      if matches[1] == '' and is_mod(msg) then
        local chat = 'chat#id'..msg.to.id
        msgr = export_chat_link('chat#id'..msg.to.id, export_chat_link_callback, {receiver=receiver, data=data, chat_id=msg.to.id, group_name=msg.to.print_name})
      end
	  end

    -- Definir {sobre|regras|nome|foto}
    if matches[1] == 'def' then
      if matches[2] == 'sobre' then
        deskripsi = matches[3]
        return set_description(msg, data)
      end
      if matches[2] == 'regras' then
        rules = matches[3]
        return set_rules(msg, data)
      end
      if matches[2] == 'nome' and is_mod(msg) then
        local new_name = string.gsub(matches[3], '_', ' ')
        data[tostring(msg.to.id)]['settings']['set_name'] = new_name
        save_data(_config.moderation.data, data)
        local group_name_set = data[tostring(msg.to.id)]['settings']['set_name']
        local to_rename = 'chat#id'..msg.to.id
        rename_chat(to_rename, group_name_set, ok_cb, false)
      end
      if matches[2] == 'img' and is_mod(msg) then
        data[tostring(msg.to.id)]['settings']['set_photo'] = 'waiting'
	      save_data(_config.moderation.data, data)
        return 'Por favor, me envie a nova foto do grupo.'
      end
	  end

    -- group lock {name|member|photo}
    if matches[1] == 'grupo' and matches[2] == 'bloq' then
      if matches[3] == 'nome' then
        return lock_group_name(msg, data)
      end
      if matches[3] == 'membros' then
        return lock_group_member(msg, data)
      end
      if matches[3] == 'img' then
        return lock_group_photo(msg, data)
      end
    end

    -- group unlock {name|member|photo}
    if matches[1] == 'grupo' and matches[2] == 'desbloq' then
      if matches[3] == 'nome' then
        return unlock_group_name(msg, data)
      end
      if matches[3] == 'membros' then
        return unlock_group_member(msg, data)
      end
      if matches[3] == 'img' then
        return unlock_group_photo(msg, data)
      end
    end

    -- if group name is renamed
    if matches[1] == 'chat_rename' then
      if not msg.service then
        return "Você é malandrão"
      end
      local group_name_set = settings.set_name
      local group_name_lock = settings.lock_name
      local to_rename = 'chat#id'..msg.to.id
      if group_name_lock == 'Sim' then
        if group_name_set ~= tostring(msg.to.print_name) then
          rename_chat(to_rename, group_name_set, ok_cb, false)
        end
      elseif group_name_lock == 'Nao' then
        return nil
      end
    end

    -- if a user added to group
    if matches[1] == 'chat_add_user' then
      if not msg.service then
        return "@Wesley_Henr"
      end
      local group_member_lock = settings.lock_member
      local user = 'user#id'..msg.action.user.id
      local chat = 'chat#id'..msg.to.id
      if group_member_lock == 'Sim' then
        chat_del_user(chat, user, ok_cb, true)
      elseif group_member_lock == 'Nao' then
        return nil
      end
    end

    -- if group photo is removed
    if matches[1] == 'chat_delete_photo' then
      if not msg.service then
        return "Meu pai?"
      end
      local group_photo_lock = settings.lock_photo
      if group_photo_lock == 'Sim' then
        chat_set_photo (receiver, settings.set_photo, ok_cb, false)
      elseif group_photo_lock == 'Nao' then
        return nil
      end
    end

    -- if group photo is changed
    if matches[1] == 'chat_change_photo' and msg.from.id ~= 0 then
      if not msg.service then
        return "Meça suas palavras"
      end
      local group_photo_lock = settings.lock_photo
      if group_photo_lock == 'Sim' then
        chat_set_photo (receiver, settings.set_photo, ok_cb, false)
      elseif group_photo_lock == 'Nao' then
        return nil
      end
    end
  end
end

return {
  description = "Gerenciador de Grupos",
  patterns = {
  "^!get(link)$",
  "^!!tgservice (.+)$",
  },
  run = run,
  hide = true,
  pre_process = pre_process
}
end
