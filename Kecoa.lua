--[[
    =====================================================
    Viccrott Hub - Versi Fullset
    Dibuat oleh: Viccrott
    =====================================================
--]]

-- ====================================================
-- == BAGIAN KONFIGURASI (Edit Bagian Ini Saja) ==
-- ====================================================

local Config = {
    HubName = "Viccrott Hub",
    Creator = "Viccrott",
    Keybind = Enum.KeyCode.RightControl,
    
    DefaultAutoFarm = false,
    DefaultAutoSell = false,
    DefaultAntiAFK = true,
    
    FarmDelay = 2,
    SellDelay = 1,
}

-- ====================================================
-- == BAGIAN UTAMA SCRIPT (JANGAN DIUBAH) ==
-- ====================================================

-- Fungsi untuk notifikasi
local function Notify(Title, Text, Duration)
    local success, err = pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = Title;
            Text = Text;
            Duration = Duration or 3;
        })
    end)
    if not success then
        warn("[Viccrott Hub] Gagal menampilkan notifikasi: " .. tostring(err))
        print("[Viccrott Hub] " .. Title .. ": " .. Text) -- Fallback ke print jika notifikasi gagal
    end
end

-- Memuat Library UI dengan deteksi error
local Library
local success, err = pcall(function()
    -- Coba muat library utama
    Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Robojini/TutHub/main/UI_Library"))()
end)

if not success then
    Notify("GAGAL MUAT UI", "Library UI tidak bisa diambil. Coba lagi nanti atau hubungi pembuat.", 10)
    warn("[Viccrott Hub] Error saat memuat Library UI: " .. tostring(err))
    return -- Hentikan script jika UI gagal dimuat
end

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
    Notify("Menukar Kode...", "Sedang mencoba semua kode.", 3)
    local codes = {"1MVISITS", "100KLIKES", "UPDATE3", "RELEASE", "FISH", "SEA", "MAGIC", "SECRET", "GOLD", "DIAMOND"}
    for i, v in pairs(codes) do
        local success, err = pcall(function()
            game:GetService("ReplicatedStorage").Events.RedeemCode:InvokeServer(v)
        end)
        if not success then
            Notify("Error", "Gagal menukar kode: " .. v, 2)
        end
    end
    Notify("Selesai!", "Semua kode yang valid sudah ditukar.", 5)
end)

-- --- FITUR ANTI-AFK --- --
local ToggleAntiAFK = MiscSection:CreateToggle("Anti-AFK", _G.AntiAFK, function(State)
    _G.AntiAFK = State
    if State then
        Notify("Anti-AFK Diaktifkan!", 3)
    else
        Notify("Anti-AFK Dinonaktifkan.", 3)
    end
end)

-- ====================================================
-- == LOGIKA DALAM LATAR BELAKANG (Dengan Deteksi Error) ==
-- ====================================================

-- Loop untuk Auto Farm
spawn(function()
    while task.wait() do
        if _G.AutoFarm then
            local success, err = pcall(function()
                game:GetService("ReplicatedStorage").Events.Fishing:FireServer("Cast")
                task.wait(Config.FarmDelay)
                game:GetService("ReplicatedStorage").Events.Fishing:FireServer("Reel")
            end)
            if not success then
                Notify("ERROR!", "Gagal memancing. Game mungkin di-update!", 5)
                _G.AutoFarm = false -- Matikan fitur untuk mencegah spam error
                ToggleFarm:SetState(false) -- Update tombol di UI
            end
        end
    end
end)

-- Loop untuk Auto Sell
spawn(function()
    while task.wait() do
        if _G.AutoSell then
            local success, err = pcall(function()
                game:GetService("ReplicatedStorage").Events.Sell:FireServer("SellAll")
            end)
            if not success then
                Notify("ERROR!", "Gagal menjual. Game mungkin di-update!", 5)
                _G.AutoSell = false -- Matikan fitur
                ToggleSell:SetState(false) -- Update tombol di UI
            end
            task.wait(Config.SellDelay)
        end
    end
end)

-- Loop untuk Anti-AFK
spawn(function()
    while task.wait() do
        if _G.AntiAFK then
            task.wait(300) -- Tunggu 5 menit
            local player = game:GetService("Players").LocalPlayer
            if player and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.Jump = true
            end
        end
    end
end)

-- Notifikasi Selamat Datang
Notify("Script Loaded!", "Selamat datang di " .. Config.HubName .. " oleh " .. Config.Creator, 5)
