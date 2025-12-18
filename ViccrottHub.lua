--[[
    =====================================================
    Viccrott Hub - Versi 1.0
    Dibuat oleh: Vvuckk
    Terima kasih sudah menggunakan script saya!
    =====================================================
--]]

-- ====================================================
-- == BAGIAN KONFIGURASI (Edit Bagian Ini Saja) ==
-- ====================================================

local Config = {
    HubName = "Viccrott Hub", -- Nama Hub yang akan muncul di UI
    Creator = "Vvuckk", -- Nama Anda yang akan muncul di notifikasi
    Keybind = Enum.KeyCode.RightControl, -- Tombol untuk membuka menu (RightControl, LeftAlt, End, P, dll.)
    
    -- Pengaturan Fitur (true = aktif, false = nonaktif saat pertama kali dijalankan)
    DefaultAutoFarm = false,
    DefaultAutoSell = false,
    DefaultAntiAFK = true,
    
    -- Pengaturan Jeda (dalam detik)
    FarmDelay = 2, -- Jeda antara lempar kail dan tarik kail
    SellDelay = 1, -- Jeda antar penjualan
}

-- ====================================================
-- == BAGIAN UTAMA SCRIPT (JANGAN DIUBAH KEcuali Anda Paham) ==
-- ====================================================

-- Memuat Library UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Robojini/TutHub/main/UI_Library"))()
local Notify = Library.Notify

-- Membuat UI
local Window = Library:CreateWindow(Config.HubName, Vector2.new(492, 498), Config.Keybind)
local MainTab = Window:CreateTab("FISH IT")
local FarmSection = MainTab:CreateSection("Auto Farm")
local SellSection = MainTab:CreateSection("Auto Sell")
local MiscSection = MainTab:CreateSection("Utilitas")

-- Variabel Global
_G.AutoFarm = Config.DefaultAutoFarm
_G.AutoSell = Config.DefaultAutoSell
_G.AntiAFK = Config.DefaultAntiAFK

-- --- FITUR AUTO FARM --- --
local ToggleFarm = FarmSection:CreateToggle("Auto Farm", _G.AutoFarm, function(State)
    _G.AutoFarm = State
    if State then
        Notify("Auto Farm Diaktifkan!", 3)
    else
        Notify("Auto Farm Dinonaktifkan.", 3)
    end
end)

-- --- FITUR AUTO SELL --- --
local ToggleSell = SellSection:CreateToggle("Auto Sell", _G.AutoSell, function(State)
    _G.AutoSell = State
    if State then
        Notify("Auto Sell Diaktifkan!", 3)
    else
        Notify("Auto Sell Dinonaktifkan.", 3)
    end
end)

-- --- FITUR REDEEM CODES --- --
local ButtonRedeem = MiscSection:CreateButton("Redeem All Codes", function()
    local codes = {"1MVISITS", "100KLIKES", "UPDATE3", "RELEASE", "FISH", "SEA", "MAGIC", "SECRET", "GOLD", "DIAMOND"}
    for i, v in pairs(codes) do
        game:GetService("ReplicatedStorage").Events.RedeemCode:InvokeServer(v)
    end
    Notify("Semua kode berhasil ditukar!", 5)
end)

-- --- FITUR ANTI-AFK (BONUS) --- --
local ToggleAntiAFK = MiscSection:CreateToggle("Anti-AFK", _G.AntiAFK, function(State)
    _G.AntiAFK = State
    if State then
        Notify("Anti-AFK Diaktifkan!", 3)
    else
        Notify("Anti-AFK Dinonaktifkan.", 3)
    end
end)

-- ====================================================
-- == LOGIKA DALAM LATAR BELAKANG (Background Loops) ==
-- ====================================================

-- Loop untuk Auto Farm
spawn(function()
    while task.wait() do -- task.wait() lebih modern dan stabil dari wait()
        if _G.AutoFarm then
            local args = {"Cast"}
            game:GetService("ReplicatedStorage").Events.Fishing:FireServer(unpack(args))
            task.wait(Config.FarmDelay)
            local args2 = {"Reel"}
            game:GetService("ReplicatedStorage").Events.Fishing:FireServer(unpack(args2))
        end
    end
end)

-- Loop untuk Auto Sell
spawn(function()
    while task.wait() do
        if _G.AutoSell then
            local args = {"SellAll"}
            game:GetService("ReplicatedStorage").Events.Sell:FireServer(unpack(args))
            task.wait(Config.SellDelay)
        end
    end
end)

-- Loop untuk Anti-AFK
spawn(function()
    while task.wait() do
        if _G.AntiAFK then
            -- Mencegah kick karena idle dengan melompat setiap 5 menit
            task.wait(300)
            game:GetService("Players").LocalPlayer.Character.Humanoid.Jump = true
        end
    end
end)

-- Notifikasi Selamat Datang
Notify("Script Loaded!", "Selamat datang di " .. Config.HubName .. " oleh " .. Config.Creator, 5)
