--[[
    shell_area mod for Minetest - Integration of ShadowNinja areas mod
    into shell mod
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


shell.register_shell("areas", "Areas protection management")

shell.register_command_from_chatcommand("areas", "protect", "protect")
shell.register_command_from_chatcommand("areas", "set_owner", "set_owner")
shell.register_command_from_chatcommand("areas", "add_owner", "add_owner")
shell.register_command_from_chatcommand("areas", "rename", "rename_area")
shell.register_command_from_chatcommand("areas", "list", "list_areas")
shell.register_command_from_chatcommand("areas", "find", "find_areas")
shell.register_command_from_chatcommand("areas", "remove", "remove_area")
shell.register_command_from_chatcommand("areas", "recursive_remove", "recursive_remove_areas")
shell.register_command_from_chatcommand("areas", "change_owner", "change_owner")
shell.register_command_from_chatcommand("areas", "info", "area_info")
shell.register_command_from_chatcommand("areas", "select", "select_area")
shell.register_command_from_chatcommand("areas", "pos", "area_pos")
shell.register_command_from_chatcommand("areas", "pos1", "area_pos1")
shell.register_command_from_chatcommand("areas", "pos2", "area_pos2")


--set,set1,set2,get 
