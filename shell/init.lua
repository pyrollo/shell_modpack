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

shell = {
	name = minetest.get_current_modname(),
	path = minetest.get_modpath(minetest.get_current_modname()),
}

dofile(shell.path.."/shell.lua")
dofile(shell.path.."/shell_base.lua")



