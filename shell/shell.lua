--[[
    shell mod for Minetest - A mod for adding a shell mode chat for test 
    purposes
    (c) Pierre-Yves Rollo

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]

-- Registered shells
local shells = {}

-- Per player environments
local player_envs = {}

-- Helpers
local function deepcopy(orig)
    if type(orig) == 'table' then
        local copy = {}
        for key, value in next, orig, nil do
            copy[deepcopy(key)] = deepcopy(value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
	    return copy
    else 
	    return orig
    end
end

local function is_valid_id(name) 
	return name:match("^[A-Za-z][A-Za-z0-9_]*$") ~= nil
end

-- Privilege declaration
minetest.register_privilege("shell",  {
	description = "Player can enter in shell mode.",
	give_to_singleplayer= true,
})

-- Default player environment
minetest.register_on_prejoinplayer(function(name, ip)
	if player_envs[name] == nil then
		player_envs[name] = {
			shell = nil, -- Shell mode off
			echo = true,   -- Echo on (see chat messages)
		}
	end
	player_envs[name].shell = nil -- Reset normal mod on join
end)

-- Commands list for a shell (+ base shell commands)
local function get_shell_commands(shell_name)
	local commands = {}
	
	if shell_name ~= 'shell' then
		for cmd_name, cmd_def in pairs(shells['shell'].commands) do
			commands[cmd_name] = cmd_def
		end
	end
	
	if shells[shell_name] then
		for cmd_name, cmd_def in 
			pairs(shells[shell_name].commands) do
			commands[cmd_name] = cmd_def
		end
	end
	return commands
end

-- Available commands list for a player
function shell.get_player_commands(name)
	if player_envs[name] and player_envs[name].shell then
		return get_shell_commands(player_envs[name].shell)
	else	
		return nil
	end
end

-- Chat hack
local send = minetest.chat_send_player

minetest.chat_send_all = function(message)
	print ("send all : "..message)
	for _,player in ipairs(minetest.get_connected_players()) do
		minetest.chat_send_player(player:get_player_name(), message)
	end
end

minetest.chat_send_player = function(name, message)
	-- Display other chat messages only if echo is set when in shell mode
	if not player_envs[name] or 
	   not player_envs[name].shell or 
	   player_envs[name].echo then
		send(name, message)
	end
end

minetest.register_on_chat_message(function(name, message)
	if player_envs[name].shell then
		-- Echo command
		send(name, "]"..message)
		local command, param = message:match("^([^ ]+)[ ]*(.*)$")

		if command == nil then
			return true
		end

		local commands = shell.get_player_commands(name)
	
		if commands[command] == nil then
			send(name, "-!- Unknown command \""..command.."\".")
			return true
		end

		if commands[command].privs then
			local ok, missing = 
				minetest.check_player_privs(name, commands[command].privs)
			if not ok then
				send(name, "-!- Missing privileges : "..missing)
				return true
			end
		end

		local status, message = commands[command].func(name, param)
		if type(message) == "string" then
			if status then
				send(name, message) 
			else
				send(name, "-!- "..message)
			end
		end
		
		return true
	end
	return false
end)

--- Registers a new shell
-- @param name Name of the shell to be used in commands
-- @param defintion Description of the shell

function shell.register_shell(name, description)
	assert(type(name) == "string", 
		"name argument should be a string.")
	assert(type(description) == "string", 
		"description argument should be a string.")
	assert(is_valid_id(name),
		"\""..name.."\" is not a valid shell name.")

	if shells[name] ~= nil then
		minetest.log("error", "["..shell.name.."] Shell \""
			..name.."\" already registered.")
	else
		shells[name] = { name = name, description = description, commands = {} }
	end
end

--- Select shell for a player (or exit shell if shell_name is nil)
-- @param player_name Player name
-- @param shell_name Shell name or nil
-- @return Error message if an error occured
function shell.select_shell(player_name, shell_name)
	if shell_name then
		if shells[shell_name] then
			player_envs[player_name].shell = shell_name
			return nil
		else
			return "\""..shell_name.."\" is not a registered shell."
		end
	else
		player_envs[player_name].shell = nil
		return nil
	end
end

--- Return the current selected shell for a player (or nil if not in shell mode)
-- @param player_name Player name
-- @return Shell description table
function shell.get_player_shell(player_name)
	if player_envs[player_name] then
		return shells[player_envs[player_name].shell]
	else
		return nil
	end
end


-- Registers a new command in a shell
-- @param shell_name Name of the shell in which register the command
-- @param name       Name of the command to register
-- @param definition Definition table of the command
-- Definition is similar to register_chatcommand definition :
-- @field func        Function to call
-- @field description Description text displayed in help
-- @field params      Parameter list displayed in help
-- @field privs       Privileges to run this command

function shell.register_command(shell_name, name, definition)
	assert(type(shell_name) == "string", 
		"shell_name argument should be a string.")
	assert(type(name) == "string", 
		"name argument should be a string.")
	assert(is_valid_id(name),
		"\""..name.."\" is not a valid command name.")
	assert(type(definition) == "table", 
		"definition argument should be a table.")
	assert(type(definition.func) == "function", 
		"definition func field should be a function.")
	assert(shells[shell_name],
		"Shell \""..shell_name.."\" is not a registered shell.")

	if shells[shell_name].commands[name] ~= nil then
		minetest.log("error", "["..shell.name.."] Command \""
			..name.."\" already registered in \""..shell_name.."\" shell.")
		return
	end

	if shells["shell"].commands[name] ~= nil then
		minetest.log("error", "["..shell.name.."] Command \""
			..name.."\" already registered in base shell.")
		return
	end
	
	shells[shell_name].commands[name] = { desctiption = "", params = "" }
	for key, value in pairs(definition) do
		shells[shell_name].commands[name][key] = deepcopy(value)
	end
	shells[shell_name].commands[name].name = name
	
end

-- Registers a new command in a shell from an existing chatcommand
-- @param shell_name  Name of the shell in which register the command
-- @param name        Name of the command to register
-- @param chatcommand Name of the chatcommand to use

function shell.register_command_from_chatcommand(shell_name, name, chatcommand)
	assert(type(shell_name) == "string", 
		"shell_name argument should be a string.")
	assert(type(name) == "string", 
		"name argument should be a string.")
	assert(type(chatcommand) == "string", 
		"chatcommand argument should be a string.")
	assert(minetest.chatcommands[chatcommand], 
		"Unregistered \""..chatcommand.."\" chatcommand.")
	assert(is_valid_id(name),
		"\""..name.."\" is not a valid command name.")

	shell.register_command(shell_name, name, minetest.chatcommands[chatcommand])
end


