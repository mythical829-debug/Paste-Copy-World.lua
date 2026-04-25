math.randomseed(os.time())

MythicalFist_Script_Vip_Auto_Geiger_GEIGER_ID   = 2204
MythicalFist_Script_Vip_Auto_Geiger_DWELL_MS    = 4000
MythicalFist_Script_Vip_Auto_Geiger_MOVE_DELAY  = 130
MythicalFist_Script_Vip_Auto_Geiger_SKIP_TOP    = 3
MythicalFist_Script_Vip_Auto_Geiger_MAX_STUCK   = 5
MythicalFist_Script_Vip_Auto_Geiger_RETRY_DELAY = 280
MythicalFist_Script_Vip_Auto_Geiger_STEP_SIZE   = 3
MythicalFist_Script_Vip_Auto_Geiger_ASTAR_MAX   = 700
MythicalFist_Script_Vip_Auto_Geiger_MAX_REPLAN  = 4
MythicalFist_Script_Vip_Auto_Geiger_VISIT_MEM   = 25

MythicalFist_Script_Vip_Auto_Geiger_isRunning          = true
MythicalFist_Script_Vip_Auto_Geiger_isReconnecting     = false
MythicalFist_Script_Vip_Auto_Geiger_savedWorldName     = nil
MythicalFist_Script_Vip_Auto_Geiger_reconnectStartTime = 0
MythicalFist_Script_Vip_Auto_Geiger_visitedTiles       = {}
MythicalFist_Script_Vip_Auto_Geiger_isPaused           = false
MythicalFist_Script_Vip_Auto_Geiger_pauseUntil         = 0
MythicalFist_Script_Vip_Auto_Geiger_resumeNotifSent    = false
MythicalFist_Script_Vip_Auto_Geiger_sbSent             = false

MythicalFist_Script_Vip_Auto_Geiger_WEBHOOK_URL = "https://discord.com/api/webhooks/1496865920914821181/YIBGZZ4NyWIGQqH-Cqki1R69fdjfwaEfn2zRnqxmWpsFqJMT_uSyBR_sCJR6sZo1pDpX"

local function IsPaused()
    return MythicalFist_Script_Vip_Auto_Geiger_isPaused
end

local function WaitIfPaused()
    if not MythicalFist_Script_Vip_Auto_Geiger_isPaused then return end
    while MythicalFist_Script_Vip_Auto_Geiger_isPaused and MythicalFist_Script_Vip_Auto_Geiger_isRunning do
        if os.time() >= MythicalFist_Script_Vip_Auto_Geiger_pauseUntil then
            MythicalFist_Script_Vip_Auto_Geiger_isPaused = false
            if not MythicalFist_Script_Vip_Auto_Geiger_resumeNotifSent then
                MythicalFist_Script_Vip_Auto_Geiger_resumeNotifSent = true
                SendVariantList({[0]='OnTextOverlay',[1]="`2Script kembali berjalan!"},-1,0)
            end
            break
        end
        Sleep(100)
    end
end

local function Notif(text)
    SendVariantList({[0]='OnTextOverlay',[1]=text},-1,0)
end

local function EscapeJSONString(str)
    if not str then return "" end
    str = string.gsub(str, "\\", "\\\\")
    str = string.gsub(str, '"', '\\"')
    str = string.gsub(str, "\n", "\\n")
    str = string.gsub(str, "\r", "\\r")
    str = string.gsub(str, "\t", "\\t")
    return str
end

local function EncodeJSONValue(val)
    local t = type(val)
    if t == "nil" then return "null"
    elseif t == "string" then return '"' .. EscapeJSONString(val) .. '"'
    elseif t == "number" then return tostring(val)
    elseif t == "boolean" then return val and "true" or "false"
    elseif t == "table" then
        local is_array = true
        local max_idx = 0
        for k, _ in pairs(val) do
            if type(k) ~= "number" or k < 1 or math.floor(k) ~= k then is_array = false break end
            if k > max_idx then max_idx = k end
        end
        if is_array then
            local elems = {}
            for i = 1, max_idx do table.insert(elems, EncodeJSONValue(val[i])) end
            return "[" .. table.concat(elems, ",") .. "]"
        else
            local elems = {}
            for k, v in pairs(val) do
                table.insert(elems, EncodeJSONValue(tostring(k)) .. ":" .. EncodeJSONValue(v))
            end
            return "{" .. table.concat(elems, ",") .. "}"
        end
    else return "null" end
end

local function GetDateTimeStr()
    local t = os.date("*t")
    local daysEn = {"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"}
    local monthsEn = {"January","February","March","April","May","June","July","August","September","October","November","December"}
    return string.format("%02d:%02d:%02d, %s %02d %s %s",
        t.hour, t.min, t.sec,
        daysEn[t.wday], t.day,
        monthsEn[t.month], tostring(t.year))
end

local function GetIndonesianDateTime()
    local t = os.date("*t")
    local hariIndo = {"Minggu","Senin","Selasa","Rabu","Kamis","Jumat","Sabtu"}
    local bulanIndo = {"Januari","Februari","Maret","April","Mei","Juni","Juli","Agustus","September","Oktober","November","Desember"}
    local waktu = string.format("%02d:%02d:%02d", t.hour, t.min, t.sec)
    local hari = hariIndo[t.wday]
    local tanggal = t.day
    local bulan = bulanIndo[t.month]
    local tahun = t.year
    return string.format("%s, %s %d %s %d", waktu, hari, tanggal, bulan, tahun)
end

local function PostWebhook(body)
    RunThread(function()
        MakeRequest(MythicalFist_Script_Vip_Auto_Geiger_WEBHOOK_URL, "POST", {["Content-Type"]="application/json"}, body, 5000)
    end)
end

local function StripColor(str)
    if not str then return "" end
    return string.gsub(tostring(str), "`.", "")
end

local function TriggerAntiCheatPause()
    if MythicalFist_Script_Vip_Auto_Geiger_isPaused then return end
    MythicalFist_Script_Vip_Auto_Geiger_isPaused       = true
    MythicalFist_Script_Vip_Auto_Geiger_pauseUntil     = os.time() + 5
    MythicalFist_Script_Vip_Auto_Geiger_resumeNotifSent = false
    SendVariantList({
        [0]="OnAddNotification",
        [1]="interface/atomic_button.rttex",
        [2]="Warning from `4System: @Anticheat-System kicks `2Detected",
        [3]="audio/hub_open.wav",
        [4]=0
    }, -1, 0)
    local player = GetLocal()
    local playerName = (player and player.name) or "Unknown"
    local embed = {
        title = "⚠️ @Anticheat-System kicks [Detected]",
        color = math.random(0, 0xFFFFFF),
        fields = {
            {name = "Nick", value = playerName, inline = false},
            {name = "⌛ Waiting For 5 Seconds For Running!", value = GetDateTimeStr(), inline = false}
        },
        footer = {text = "Auto Geiger | Dr.MythicalFist"}
    }
    PostWebhook(EncodeJSONValue({embeds = {embed}}))
end

local function CheckAntiCheatStr(s)
    if not s then return false end
    local c = StripColor(s):lower()
    return c:find("anticheat%-system kicks") ~= nil
        or c:find("anticheat.system kicks") ~= nil
        or c:find("cheating of type")        ~= nil
        or c:find("speedhack")               ~= nil
end

local function SendStartWebhook()
    local player = GetLocal()
    if not player then return end
    local world = GetWorld()
    if not world or world.name == "EXIT" then return end
    local playerName = player.name or "Unknown"
    local playerUID  = player.userid or "?"
    local worldName  = world.name:upper()
    local worldSize  = string.format("%dx%d", world.width or 0, world.height or 0)
    local playerList = GetPlayerList()
    local playersInfo = {}
    table.insert(playersInfo, string.format("%s (UID: %s)", playerName, tostring(playerUID)))
    for _, plr in ipairs(playerList) do
        table.insert(playersInfo, string.format("%s (UID: %s)", plr.name, tostring(plr.userid or "?")))
    end
    local playersText = table.concat(playersInfo, "\n")
    if #playersText > 1024 then playersText = playersText:sub(1, 1020) .. "..." end
    local geigerCount, geigerName = 0, ""
    for _, item in pairs(GetInventory()) do
        if item.id == MythicalFist_Script_Vip_Auto_Geiger_GEIGER_ID then
            geigerCount = geigerCount + item.amount
            if geigerName == "" then
                local info = GetItemInfo(MythicalFist_Script_Vip_Auto_Geiger_GEIGER_ID)
                if info then geigerName = info.name end
            end
        end
    end
    local geigerText = (geigerCount > 0)
        and string.format("%s x%d (ID:%d)", geigerName, geigerCount, MythicalFist_Script_Vip_Auto_Geiger_GEIGER_ID)
        or "Tidak ada Geiger Counter di inventory"
    local embed = {
        title = "📡 Auto Geiger Script V1",
        color = math.random(0, 0xFFFFFF),
        fields = {
            {name = "🪪 Information Account",              value = playerName .. " (UID: " .. playerUID .. ")", inline = false},
            {name = "🌐 Information World",                value = worldName,    inline = false},
            {name = "⚠️ Player In The World",             value = playersText,  inline = false},
            {name = "🌏 Size World",                      value = worldSize,    inline = false},
            {name = "🔎 Geiger Counter In The Inventory", value = geigerText,   inline = false},
            {name = "🗓️ Waktu Pemakaian Script",         value = GetDateTimeStr(), inline = false}
        },
        footer = {text = "Auto Geiger | Dr.MythicalFist"}
    }
    PostWebhook(EncodeJSONValue({embeds = {embed}}))
end

local function SendSuperBroadcast()
    if MythicalFist_Script_Vip_Auto_Geiger_sbSent then return end
    MythicalFist_Script_Vip_Auto_Geiger_sbSent = true
    local datetime = GetIndonesianDateTime()
    local sbText = string.format("`1NOW `4Script Geiger `^V1 `2Active `5By: `4Dr.MythicalFist `#%s", datetime)
    SendPacket(2, "action|input\n|text|/sb " .. sbText)
end

local function SendDisconnectWebhook()
    local player = GetLocal()
    local embed = {
        title = "❌ Disconnect With Server",
        color = 0xFF0000,
        fields = {
            {name = "🪪 Information Account", value = ((player and player.name) or "Unknown") .. " (UID: " .. ((player and tostring(player.userid)) or "?") .. ")", inline = false},
            {name = "🌐 Information World",   value = MythicalFist_Script_Vip_Auto_Geiger_savedWorldName or "Unknown", inline = false},
            {name = "🌐 Network",             value = "Ping: 999 ms", inline = false},
            {name = "🗓️ Waktu Kejadian",     value = GetDateTimeStr(), inline = false}
        },
        footer = {text = "Auto Geiger | Dr.MythicalFist"}
    }
    PostWebhook(EncodeJSONValue({embeds = {embed}}))
end

local function SendReconnectWebhook(durationMs, ping)
    local player = GetLocal()
    local embed = {
        title = "✅ Reconnect Success",
        color = math.random(0, 0xFFFFFF),
        fields = {
            {name = "🪪 Information Account", value = ((player and player.name) or "Unknown") .. " (UID: " .. ((player and tostring(player.userid)) or "?") .. ")", inline = false},
            {name = "🌐 Information World",   value = MythicalFist_Script_Vip_Auto_Geiger_savedWorldName or "Unknown", inline = false},
            {name = "🌐 Network",             value = string.format("Ping: %d ms", ping), inline = false},
            {name = "⏳ Time Reconnect",      value = string.format("%.2f seconds", durationMs / 1000), inline = false},
            {name = "🗓️ Waktu Pemakaian Script", value = GetDateTimeStr(), inline = false}
        },
        footer = {text = "Auto Geiger | Dr.MythicalFist"}
    }
    PostWebhook(EncodeJSONValue({embeds = {embed}}))
end

local function JoinWorld(worldName)
    if not worldName or worldName == "" then return end
    SendPacket(3, "action|join_request\nname|" .. worldName .. "\ninvitedWorld|0")
end

local function Reconnect()
    if MythicalFist_Script_Vip_Auto_Geiger_isReconnecting then return end
    MythicalFist_Script_Vip_Auto_Geiger_isReconnecting = true
    Notif("`5Terputus dari server, mencoba reconnect...")
    SendDisconnectWebhook()
    local startTime   = os.clock() * 1000
    local maxAttempts = 30
    local attempt     = 0
    while MythicalFist_Script_Vip_Auto_Geiger_isRunning and attempt < maxAttempts do
        attempt = attempt + 1
        JoinWorld(MythicalFist_Script_Vip_Auto_Geiger_savedWorldName)
        Sleep(3000)
        local world = GetWorld()
        if world and world.name ~= "EXIT" and world.name == MythicalFist_Script_Vip_Auto_Geiger_savedWorldName then
            local duration = (os.clock() * 1000) - startTime
            local ping = 0
            pcall(function() ping = GetClient().ping or 0 end)
            SendReconnectWebhook(duration, ping)
            Notif("`2Berhasil reconnect ke " .. MythicalFist_Script_Vip_Auto_Geiger_savedWorldName)
            MythicalFist_Script_Vip_Auto_Geiger_isReconnecting = false
            return true
        end
        Sleep(2000)
    end
    MythicalFist_Script_Vip_Auto_Geiger_isReconnecting = false
    Notif("`4Gagal reconnect setelah 30 percobaan, script berhenti.")
    MythicalFist_Script_Vip_Auto_Geiger_isRunning = false
    return false
end

local function PlayerTile()
    local p = GetLocal()
    if not p then return 0, 0 end
    return math.floor(p.pos.x / 32), math.floor(p.pos.y / 32)
end

local function GetWorldBounds()
    local w = GetWorld()
    if not w then return 0, 0 end
    return tonumber(w.width) or 0, tonumber(w.height) or 0
end

local function HasGeiger()
    for _, item in pairs(GetInventory()) do
        if item.id == MythicalFist_Script_Vip_Auto_Geiger_GEIGER_ID then return true end
    end
    return false
end

local function Heuristic(ax, ay, bx, by)
    return math.abs(ax - bx) + math.abs(ay - by)
end

local function AStarPath(sx, sy, tx, ty)
    local W, H = GetWorldBounds()
    if W <= 0 or H <= 0 then return nil end
    local function Key(x, y) return y * W + x end
    local open, closed, gScore = {}, {}, {}
    gScore[Key(sx, sy)] = 0
    table.insert(open, {x = sx, y = sy, g = 0, f = Heuristic(sx, sy, tx, ty), parent = nil})
    local function PopMin()
        local mi, mf = 1, open[1].f
        for i = 2, #open do if open[i].f < mf then mi, mf = i, open[i].f end end
        local nd = open[mi]
        table.remove(open, mi)
        return nd
    end
    local DIRS = {{0,1},{0,-1},{1,0},{-1,0}}
    local iter = 0
    while #open > 0 do
        iter = iter + 1
        if iter > MythicalFist_Script_Vip_Auto_Geiger_ASTAR_MAX then break end
        local curr = PopMin()
        local ck   = Key(curr.x, curr.y)
        if not closed[ck] then
            closed[ck] = true
            if curr.x == tx and curr.y == ty then
                local path, node = {}, curr
                while node do
                    table.insert(path, 1, {x = node.x, y = node.y})
                    node = node.parent
                end
                return path
            end
            for _, d in ipairs(DIRS) do
                local nx, ny = curr.x + d[1], curr.y + d[2]
                if nx >= 0 and nx < W and ny >= MythicalFist_Script_Vip_Auto_Geiger_SKIP_TOP and ny < H then
                    local nk = Key(nx, ny)
                    if not closed[nk] and CheckPath(nx, ny) then
                        local ng = curr.g + 1
                        if not gScore[nk] or ng < gScore[nk] then
                            gScore[nk] = ng
                            local h = Heuristic(nx, ny, tx, ty)
                            table.insert(open, {x = nx, y = ny, g = ng, f = ng + h + 0.001 * h, parent = curr})
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function WalkTo(tx, ty)
    local function CPos() return PlayerTile() end
    local function Plan()
        local lx, ly = CPos()
        return AStarPath(lx, ly, tx, ty)
    end
    local cx, cy = CPos()
    if cx == tx and cy == ty then return true end
    local path = Plan()
    if not path or #path < 2 then return false end
    local step, stuck, replan = 2, 0, 0
    while MythicalFist_Script_Vip_Auto_Geiger_isRunning do
        if IsPaused() then return false end
        local curX, curY = CPos()
        if curX == tx and curY == ty then return true end
        if step > #path then return false end
        local ji   = math.min(step + MythicalFist_Script_Vip_Auto_Geiger_STEP_SIZE - 1, #path)
        local node = path[ji]
        if not CheckPath(node.x, node.y) then
            path = Plan()
            replan = replan + 1
            if not path or #path < 2 or replan > MythicalFist_Script_Vip_Auto_Geiger_MAX_REPLAN then return false end
            step = 2
        else
            local prevX, prevY = CPos()
            FindPath(node.x, node.y)
            local dist = math.abs(node.x - prevX) + math.abs(node.y - prevY)
            Sleep(math.max(MythicalFist_Script_Vip_Auto_Geiger_MOVE_DELAY, dist * MythicalFist_Script_Vip_Auto_Geiger_MOVE_DELAY + 40))
            if IsPaused() then return false end
            local nx, ny = CPos()
            if nx == prevX and ny == prevY then
                stuck = stuck + 1
                if stuck >= MythicalFist_Script_Vip_Auto_Geiger_MAX_STUCK then
                    path = Plan()
                    replan = replan + 1
                    if not path or #path < 2 or replan > MythicalFist_Script_Vip_Auto_Geiger_MAX_REPLAN then return false end
                    step  = 2
                    stuck = 0
                else
                    for _, e in ipairs({{nx+1,ny},{nx-1,ny},{nx,ny+1},{nx,ny-1}}) do
                        if CheckPath(e[1], e[2]) then
                            FindPath(e[1], e[2])
                            Sleep(MythicalFist_Script_Vip_Auto_Geiger_RETRY_DELAY)
                            break
                        end
                    end
                end
            else
                stuck = 0
                local synced = false
                for i = step, #path do
                    if path[i].x == nx and path[i].y == ny then
                        step   = i + 1
                        synced = true
                        break
                    end
                end
                if not synced then
                    path = Plan()
                    replan = replan + 1
                    if not path or #path < 2 or replan > MythicalFist_Script_Vip_Auto_Geiger_MAX_REPLAN then return false end
                    step = 2
                end
                if nx == tx and ny == ty then return true end
            end
        end
    end
    return false
end

local function IsVisited(x, y)
    for _, v in ipairs(MythicalFist_Script_Vip_Auto_Geiger_visitedTiles) do
        if v[1] == x and v[2] == y then return true end
    end
    return false
end

local function MarkVisited(x, y)
    table.insert(MythicalFist_Script_Vip_Auto_Geiger_visitedTiles, {x, y})
    if #MythicalFist_Script_Vip_Auto_Geiger_visitedTiles > MythicalFist_Script_Vip_Auto_Geiger_VISIT_MEM then
        table.remove(MythicalFist_Script_Vip_Auto_Geiger_visitedTiles, 1)
    end
end

local function RandomWalkableTile()
    local W, H = GetWorldBounds()
    if W <= 0 or H <= 0 then return nil end
    for _ = 1, 80 do
        local x = math.random(0, W - 1)
        local y = math.random(MythicalFist_Script_Vip_Auto_Geiger_SKIP_TOP, H - 1)
        if CheckPath(x, y) and not IsVisited(x, y) then
            MarkVisited(x, y)
            return x, y
        end
    end
    local cx, cy = PlayerTile()
    for r = 1, 10 do
        for dy = -r, r do
            for dx = -r, r do
                local nx, ny = cx + dx, cy + dy
                if nx >= 0 and nx < W and ny >= MythicalFist_Script_Vip_Auto_Geiger_SKIP_TOP and ny < H
                    and CheckPath(nx, ny) and not IsVisited(nx, ny) then
                    MarkVisited(nx, ny)
                    return nx, ny
                end
            end
        end
    end
    return cx, cy
end

AddHook('OnVariant', 'AC_VarHook', function(var, netid, delay)
    if type(var) ~= "table" then return end
    local name = tostring(var[0] or "")
    if name == "OnAddNotification" then
        for i = 0, 5 do
            if CheckAntiCheatStr(var[i]) then
                TriggerAntiCheatPause()
                return false
            end
        end
    end
    if name == "OnConsoleMessage" then
        if CheckAntiCheatStr(var[1]) then
            TriggerAntiCheatPause()
            return false
        end
    end
end)

AddHook('OnReceivePacket', 'AC_PktHook', function(packet)
    if type(packet) ~= "table" then return end
    if packet.type == 3 then
        if CheckAntiCheatStr(packet.text) then
            TriggerAntiCheatPause()
        end
    end
end)

local initWorld = GetWorld()
if initWorld and initWorld.name ~= "EXIT" then
    MythicalFist_Script_Vip_Auto_Geiger_savedWorldName = initWorld.name
end
SendStartWebhook()
SendSuperBroadcast()

RunThread(function()
    while MythicalFist_Script_Vip_Auto_Geiger_isRunning do
        WaitIfPaused()
        Sleep(3000)
        if not MythicalFist_Script_Vip_Auto_Geiger_isRunning then break end
        if MythicalFist_Script_Vip_Auto_Geiger_isReconnecting then goto rc_continue end
        if IsPaused() then goto rc_continue end
        local world  = GetWorld()
        local client = nil
        pcall(function() client = GetClient() end)
        local connected = (world and world.name ~= "EXIT" and world.name ~= nil)
        if not connected or (client and client.ping == nil) then
            if MythicalFist_Script_Vip_Auto_Geiger_savedWorldName then
                Reconnect()
            else
                MythicalFist_Script_Vip_Auto_Geiger_isRunning = false
                break
            end
        end
        ::rc_continue::
    end
end)

RunThread(function()
    while MythicalFist_Script_Vip_Auto_Geiger_isRunning do
        WaitIfPaused()
        if MythicalFist_Script_Vip_Auto_Geiger_isReconnecting then
            Sleep(1000)
            goto main_skip
        end
        local world = GetWorld()
        if not world or world.name == "EXIT" then
            Sleep(500)
            goto main_skip
        end
        if not HasGeiger() then
            MythicalFist_Script_Vip_Auto_Geiger_isRunning = false
            Notif("`4Geiger Counter habis! Script berhenti.")
            break
        end
        SetItemSelected(MythicalFist_Script_Vip_Auto_Geiger_GEIGER_ID)
        local tx, ty = RandomWalkableTile()
        if not tx then
            Sleep(500)
        else
            local reached = WalkTo(tx, ty)
            if IsPaused() then goto main_skip end
            if reached then
                local elapsed = 0
                while elapsed < MythicalFist_Script_Vip_Auto_Geiger_DWELL_MS
                    and MythicalFist_Script_Vip_Auto_Geiger_isRunning
                    and not IsPaused() do
                    Sleep(200)
                    elapsed = elapsed + 200
                end
                if IsPaused() then WaitIfPaused() end
            else
                Sleep(400)
            end
        end
        ::main_skip::
    end
end)
