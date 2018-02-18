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

-- Messages

-- 
local function echo_message(name)
--[[	if player_envs[name].echo then
		return "Echo is ON"
	else
		return "Echo is OFF"
	end
--]]
end

--
local function shell_message(name)
	local selected_shell = shell.get_player_shell(name)
	if selected_shell.name == "shell" then
		return "No selected shell, use shell <shell_name> to select one."
	else
		if selected_shell.description then
			return "Selected shell \""..selected_shell.name.."\": "
				..selected_shell.description
		else
			return "Selected shell \""..selected_shell.name.."\"."
		end
	end
end

-- Common functions

--
local function select_shell(player_name, shell_name)
	local message
	if shell_name and shell_name ~= "" then
		message = shell.select_shell(player_name, shell_name)
	else
		-- Default basic shell
		message = shell.select_shell(player_name, "shell")
	end
	return message
end

-- Base shell (default commands, usable in every shell)
shell.register_shell("shell", "Base shell commands")

-- Exit command
shell.register_command("shell", "exit", {
	func = function(name)
		shell.select_shell(name, nil)
		return true, "Leaving shell mode."
	end,
	description = "Leave the shell mode",
})

-- Shell command
shell.register_command("shell", "shell", {
	func = function(name, shell_name)
		local message = select_shell(name, shell_name)
		if message then
			return false, message
		else
			return true, shell_message(name)
		end
	end,
	param = "<shell>",
	description = "Changing to another shell",
})

-- Echo on/off command
shell.register_command("shell", "echo", {
	func = function(name, param)
--[[		if param and param ~= "" then
			if param:upper() == "ON" then
				player_envs[name].echo = true
			end
			if param:upper() == "OFF" then
				player_envs[name].echo = false
			end
		end
		return true, echo_message(name)
--]]	end,
	param = "[ON|OFF]",
	description = "Enable or disable incomming message while in shell",
})

-- Help command
shell.register_command("shell", "help", {
	func = function(name, param)
		local commands = shell.get_player_commands(name)
		local message = ""
		
		if param == "" then
			-- Generic help - command list
			message = "You are in shell mod. Type \"exit\" to leave.\n"
			message = message..shell_message(name)
			message = message.."\nAvailable commands are:"
			local text

			for command, def in pairs(commands) do
				text = command
				if def.description ~= "" then
					text = text..": "..def.description
				end
				message = message.."\n"..text
			end
		else
			-- Help on a command
			if commands[param] ~= nil then
				message = param
				def = commands[param]
				if def.params ~= "" then
					message = message.." "..def.params
				end
				if def.description ~= "" then
					message = message.."\n"..def.description
				end
			else
				message = "Unknown command \""..param.."\"."
			end
		end
		return true, message
	end,
	params = "<command>",
	description = "Help on a command or list commands",
})

-- Shell chatcommand
minetest.register_chatcommand("shell", 
{
	params = "<shell>",
	description = "Enter in shell mode",
	privs = {shell=true}, 

	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "Player not found"
		end
		if select_shell(name, param) then
			return true, "Entering shell mode, type \"exit\" to leave.\n"..
				shell_message(name)
		end
	end,
})

