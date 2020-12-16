-- Version 1.7.1.3
-- ONLY COPY THIS WHOLE FILE IS YOU ARE GOING TO HOST A SERVER!
-- The file must be in Saved Games\DCS\Scripts\Hooks or Saved Games\DCS.openalpha\Scripts\Hooks
-- Make sure you enter the correct address into SERVER_SRS_HOST below.
-- You can add an optional Port. e.g. "127.0.0.1:5002"
-- You can also enable SRS Chat commands to list frequencies and a message to all 
-- non SRS connected users to encourage them to connect

-- User options --
local SRSAuto = {}
SRSAuto.SERVER_SRS_HOST = "srs.redstormrising.net:5002"
SRSAuto.SERVER_SEND_AUTO_CONNECT = true -- set to false to disable auto connect or just remove this file

---- SRS CHAT COMMANDS ----
SRSAuto.CHAT_COMMANDS_ENABLED = true -- if true type -freq, -freqs or -frequencies in ALL chat in multilayer to see the frequencies

SRSAuto.SRS_FREQUENCIES = {
    ["red"] = "GCI-AWACS: 121.000\\\nEWR:124.000\\\nBasket Tanker 141.000\\\nBoom Tanker 142.000", -- edit this to the red frequency list
    ["blue"] = "GCI-AWACS: 251.000\\\nEWR:124.000\\\nBasket Tanker 141.000\\\nBoom Tanker 142.000\\\nRecovery Tanker 143.000", -- edit this to the blue frequency list
    ["neutral"] = "", -- edit this to the spectator frequency list
}

---- SRS NUDGE MESSAGE ----
SRSAuto.SRS_NUDGE_ENABLED = true -- set to true to enable the message below
SRSAuto.SRS_NUDGE_TIME = 1200 -- SECONDS between messages to non connected SRS users
SRSAuto.SRS_MESSAGE_TIME = 10 -- SECONDS to show the message for
SRSAuto.SRS_NUDGE_PATH = "C:\\Program Files\\DCS-SimpleRadio-Standalone\\clients-list.json" -- path to SERVER JSON EXPORT - enable Auto Export List on the server
--- EDIT the message below to change what is said to users - DONT USE QUOTES - either single or double due to the injection into SRS it'll fail
--- Newlines must be escaped like so: \\\n with 3 backslashes
SRSAuto.SRS_NUDGE_MESSAGE = "Red Storm Rising (RSR) Syria - Slot load times vary by client setup, we have seen it take upwards of a couple of minutes for the client to load into the mission. ONCE YOU SELECT A SLOT YOU WILL BE SIDE LOCKED UNTIL MISSION RESTART (every 8 Hours)\\\n\\\n****** DCS IS BETTER WITH COMMS - PLEASE USE SRS AND/OR DISCORD (https://discord.gg/NRvtGax) ******\\\n\\\nComms with other players will help you to be more effective, find enemies and wingmen, or call in support \\\n\\\nGood comms and teamwork will help YOU and your team win! "


-- DO NOT EDIT BELOW HERE --

SRSAuto.unicast = true

-- Utils --
local HOST_PLAYER_ID = 1

SRSAuto.MESSAGE_PREFIX = "SRS Running @ " -- DO NOT MODIFY!!!

package.path = package.path .. ";.\\LuaSocket\\?.lua;"
package.cpath = package.cpath .. ";.\\LuaSocket\\?.dll;"

local JSON = loadfile("Scripts\\JSON.lua")()
SRSAuto.JSON = JSON

local socket = require("socket")

SRSAuto.UDPSendSocket = socket.udp()
SRSAuto.UDPSendSocket:settimeout(0)

SRSAuto.logFile = io.open(lfs.writedir() .. [[Logs\DCS-SRS-AutoConnect.log]], "w")

function SRSAuto.log(str)
    if SRSAuto.logFile then
        SRSAuto.logFile:write(str .. "\n")
        SRSAuto.logFile:flush()
    end
end

-- Register callbacks --

SRSAuto.onPlayerConnect = function(id)
    if not DCS.isServer() then
        return
    end
    if SRSAuto.SERVER_SEND_AUTO_CONNECT and id ~= HOST_PLAYER_ID then
        SRSAuto.log(string.format("Sending auto connect message to player %d on connect ", id))
        net.send_chat_to(string.format(SRSAuto.MESSAGE_PREFIX .. "%s", SRSAuto.SERVER_SRS_HOST), id)
    end
end

SRSAuto.onPlayerChangeSlot = function(id)
    if not DCS.isServer() then
        return
    end
    if SRSAuto.SERVER_SEND_AUTO_CONNECT and id ~= HOST_PLAYER_ID then
        SRSAuto.log(string.format("Sending auto connect message to player %d on switch ", id))
        net.send_chat_to(string.format(SRSAuto.MESSAGE_PREFIX .. "%s", SRSAuto.SERVER_SRS_HOST), id)
    end
end

SRSAuto.trimStr = function(_str)
    return string.format("%s", _str:match("^%s*(.-)%s*$"))
end

SRSAuto.onChatMessage = function(message, playerID)
    local _msg = string.lower(SRSAuto.trimStr(message))

    if _msg == "-freq" or _msg == "-frequencies" or _msg == "-freqs" then

        local _player = net.get_player_info(playerID)

        local _freq = ""

        if _player.coa == 0 then
            _freq = SRSAuto.SRS_FREQUENCIES.neutral
        elseif _player.coa == 1 then
            _freq = SRSAuto.SRS_FREQUENCIES.red
        else
            _freq = SRSAuto.SRS_FREQUENCIES.blue
        end

        local _chatMessage = string.format("*** SRS: %s ***", _freq)
        net.send_chat_to(_chatMessage, _player.id)
        return
    end
end

local _lastSent = 0

SRSAuto.onSimulationFrame = function()

    if SRSAuto.SRS_NUDGE_ENABLED then

        if not DCS.isServer() then
            return
        end

        local _now = os.time()

        -- send every 5 seconds
        if _now > _lastSent + SRSAuto.SRS_NUDGE_TIME then
            _lastSent = _now

            SRSAuto.srsNudge()
        end
    end
end

SRSAuto.readFile = function(path)
    local file = io.open(path, "rb") -- r read mode and b binary mode
    if not file then
        return nil
    end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end

SRSAuto.srsNudge = function()

    SRSAuto.log("SRS NUDGE Running")

    local _status, _result = pcall(function()

        local _playerByName = {}
        for _, v in pairs(net.get_player_list()) do

            local _player = net.get_player_info(v)

            if _player.side ~= 0 then

                _playerByName[_player.name] = _player
                --SRSAuto.log("SRS NUDGE - Added ".._player.name)

            end

        end
        local fileContent = SRSAuto.readFile(SRSAuto.SRS_NUDGE_PATH);

        local srs = {}
        srs = SRSAuto.JSON:decode(fileContent)

        if srs and srs.Clients then
            srs = srs.Clients
            -- loop through SRS and remove players
            for _, _srsPlayer in pairs(srs) do
                _playerByName[_srsPlayer.Name] = nil
                --SRSAuto.log("SRS NUDGE - Removed ".._srsPlayer.Name)
            end

            -- loop through remaining and nudge
            for _name, _player in pairs(_playerByName) do

                local _group = DCS.getUnitProperty(_player.slot, DCS.UNIT_GROUP_MISSION_ID)

                if _group then

                    SRSAuto.log("SRS NUDGE - Messaging " .. _player.name)
                    SRSAuto.sendMessage(SRSAuto.SRS_NUDGE_MESSAGE, SRSAuto.SRS_MESSAGE_TIME, _group)

                end
            end
        end
    end)

    if not _status then
        SRSAuto.log('ERROR: ' .. _result)
    end


end

SRSAuto.sendMessage = function(msg, showTime, gid)
    if gid then
        local str = "trigger.action.outTextForGroup(" .. gid .. ",'" .. msg .. "'," .. showTime .. ",true); return true;"
        local _status, _error = net.dostring_in('server', str)
        if not _status and _error then
            SRSAuto.log("Error! " .. _error)
        end
    else
        local str = "trigger.action.outText('" .. msg .. "'," .. showTime .. ",true); return true;"
        local _status, _error = net.dostring_in('server', str)
        if not _status and _error then
            SRSAuto.log("Error! " .. _error)
        end
    end
end

DCS.setUserCallbacks(SRSAuto)
net.log("Loaded - DCS-SRS-AutoConnect 1.7.1.3")