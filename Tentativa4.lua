-- Delta Android: Telecinese + Ímã de Blocos (CORRIGIDO)
-- Bug do abismo corrigido | Telecinese controlada pelo mouse

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- ==================== CONFIGURAÇÕES ====================
local CONFIG = {
    Ativado = false,
    Distancia = 100,
    Velocidade = 50,
    MinValor = 10,
    MaxValor = 200,
    Passo = 10,
    ForcaArremesso = 250,
    DanoArremesso = 30,
    TelecineseAtiva = false,
    BlocoTelecinese = nil,
    AlturaTelecinese = 15, -- Altura que o bloco fica acima do chão
    DistanciaFrente = 12  -- Distância à frente do jogador
}

local partesControladas = {}
local conexoes = {}

-- ==================== NETWORK OWNERSHIP ====================
local function pegarOwnership(parte)
    pcall(function()
        parte:SetNetworkOwner(player)
    end)
end

-- ==================== GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TelecineseGUI"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local Janela = Instance.new("Frame")
Janela.Name = "Janela"
Janela.Parent = ScreenGui
Janela.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Janela.BorderSizePixel = 0
Janela.Position = UDim2.new(0.1, 0, 0.15, 0)
Janela.Size = UDim2.new(0, 280, 0, 440)
Janela.Active = true
Janela.Draggable = true
Janela.ClipsDescendants = true

local Canto = Instance.new("UICorner")
Canto.CornerRadius = UDim.new(0, 8)
Canto.Parent = Janela

-- Barra de título
local BarraTitulo = Instance.new("Frame")
BarraTitulo.Name = "BarraTitulo"
BarraTitulo.Parent = Janela
BarraTitulo.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
BarraTitulo.BorderSizePixel = 0
BarraTitulo.Size = UDim2.new(1, 0, 0, 35)

local Titulo = Instance.new("TextLabel")
Titulo.Parent = BarraTitulo
Titulo.BackgroundTransparency = 1
Titulo.Position = UDim2.new(0, 10, 0, 0)
Titulo.Size = UDim2.new(1, -80, 1, 0)
Titulo.Font = Enum.Font.GothamBold
Titulo.Text = "Telecinese [DESLIGADO]"
Titulo.TextColor3 = Color3.fromRGB(255, 100, 100)
Titulo.TextSize = 14
Titulo.TextXAlignment = Enum.TextXAlignment.Left

local BotaoMin = Instance.new("TextButton")
BotaoMin.Parent = BarraTitulo
BotaoMin.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
BotaoMin.BorderSizePixel = 0
BotaoMin.Position = UDim2.new(1, -70, 0, 5)
BotaoMin.Size = UDim2.new(0, 28, 0, 25)
BotaoMin.Font = Enum.Font.GothamBold
BotaoMin.Text = "—"
BotaoMin.TextColor3 = Color3.fromRGB(255, 255, 255)
BotaoMin.TextSize = 16

local CantoMin = Instance.new("UICorner")
CantoMin.CornerRadius = UDim.new(0, 4)
CantoMin.Parent = BotaoMin

local BotaoFechar = Instance.new("TextButton")
BotaoFechar.Parent = BarraTitulo
BotaoFechar.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
BotaoFechar.BorderSizePixel = 0
BotaoFechar.Position = UDim2.new(1, -35, 0, 5)
BotaoFechar.Size = UDim2.new(0, 28, 0, 25)
BotaoFechar.Font = Enum.Font.GothamBold
BotaoFechar.Text = "×"
BotaoFechar.TextColor3 = Color3.fromRGB(255, 255, 255)
BotaoFechar.TextSize = 18

local CantoFechar = Instance.new("UICorner")
CantoFechar.CornerRadius = UDim.new(0, 4)
CantoFechar.Parent = BotaoFechar

-- Área de conteúdo com rolagem
local Area = Instance.new("ScrollingFrame")
Area.Parent = Janela
Area.BackgroundTransparency = 1
Area.Position = UDim2.new(0, 8, 0, 42)
Area.Size = UDim2.new(1, -16, 1, -50)
Area.CanvasSize = UDim2.new(0, 0, 0, 480)
Area.ScrollBarThickness = 6
Area.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 120)
Area.BorderSizePixel = 0

-- ==================== BOTÃO ÍMÃ ====================
local BotaoIma = Instance.new("TextButton")
BotaoIma.Parent = Area
BotaoIma.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
BotaoIma.BorderSizePixel = 0
BotaoIma.Position = UDim2.new(0, 0, 0, 0)
BotaoIma.Size = UDim2.new(1, 0, 0, 38)
BotaoIma.Font = Enum.Font.GothamBold
BotaoIma.Text = "Ímã de Blocos: DESLIGADO"
BotaoIma.TextColor3 = Color3.fromRGB(255, 255, 255)
BotaoIma.TextSize = 13

local CantoIma = Instance.new("UICorner")
CantoIma.CornerRadius = UDim.new(0, 6)
CantoIma.Parent = BotaoIma

-- ==================== BOTÃO TELECINESE ====================
local BotaoTele = Instance.new("TextButton")
BotaoTele.Parent = Area
BotaoTele.BackgroundColor3 = Color3.fromRGB(80, 60, 160)
BotaoTele.BorderSizePixel = 0
BotaoTele.Position = UDim2.new(0, 0, 0, 48)
BotaoTele.Size = UDim2.new(1, 0, 0, 45)
BotaoTele.Font = Enum.Font.GothamBold
BotaoTele.Text = "🧠 ATIVAR TELECINESE"
BotaoTele.TextColor3 = Color3.fromRGB(255, 255, 255)
BotaoTele.TextSize = 14

local CantoTele = Instance.new("UICorner")
CantoTele.CornerRadius = UDim.new(0, 6)
CantoTele.Parent = BotaoTele

-- Instrução
local Instrucao = Instance.new("TextLabel")
Instrucao.Parent = Area
Instrucao.BackgroundTransparency = 1
Instrucao.Position = UDim2.new(0, 0, 0, 98)
Instrucao.Size = UDim2.new(1, 0, 0, 30)
Instrucao.Font = Enum.Font.Gotham
Instrucao.Text = "Toque em um bloco para pegá-lo"
Instrucao.TextColor3 = Color3.fromRGB(180, 180, 255)
Instrucao.TextSize = 11
Instrucao.TextWrapped = true

-- ==================== SLIDER DISTÂNCIA ====================
local LabelDist = Instance.new("TextLabel")
LabelDist.Parent = Area
LabelDist.BackgroundTransparency = 1
LabelDist.Position = UDim2.new(0, 0, 0, 132)
LabelDist.Size = UDim2.new(1, 0, 0, 20)
LabelDist.Font = Enum.Font.Gotham
LabelDist.Text = "Distância (Ímã): 100"
LabelDist.TextColor3 = Color3.fromRGB(200, 200, 255)
LabelDist.TextSize = 12
LabelDist.TextXAlignment = Enum.TextXAlignment.Left

local SliderDist = Instance.new("Frame")
SliderDist.Parent = Area
SliderDist.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
SliderDist.BorderSizePixel = 0
SliderDist.Position = UDim2.new(0, 0, 0, 155)
SliderDist.Size = UDim2.new(1, 0, 0, 8)

local FillDist = Instance.new("Frame")
FillDist.Parent = SliderDist
FillDist.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
FillDist.BorderSizePixel = 0
FillDist.Size = UDim2.new(0.5, 0, 1, 0)

local KnobDist = Instance.new("Frame")
KnobDist.Parent = SliderDist
KnobDist.BackgroundColor3 = Color3.fromRGB(180, 180, 255)
KnobDist.BorderSizePixel = 0
KnobDist.Size = UDim2.new(0, 16, 0, 16)
KnobDist.Position = UDim2.new(0.5, -8, 0, -4)

local CantoKnobD = Instance.new("UICorner")
CantoKnobD.CornerRadius = UDim.new(1, 0)
CantoKnobD.Parent = KnobDist

-- ==================== SLIDER VELOCIDADE ====================
local LabelVel = Instance.new("TextLabel")
LabelVel.Parent = Area
LabelVel.BackgroundTransparency = 1
LabelVel.Position = UDim2.new(0, 0, 0, 182)
LabelVel.Size = UDim2.new(1, 0, 0, 20)
LabelVel.Font = Enum.Font.Gotham
LabelVel.Text = "Velocidade (Ímã): 50"
LabelVel.TextColor3 = Color3.fromRGB(200, 255, 200)
LabelVel.TextSize = 12
LabelVel.TextXAlignment = Enum.TextXAlignment.Left

local SliderVel = Instance.new("Frame")
SliderVel.Parent = Area
SliderVel.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
SliderVel.BorderSizePixel = 0
SliderVel.Position = UDim2.new(0, 0, 0, 205)
SliderVel.Size = UDim2.new(1, 0, 0, 8)

local FillVel = Instance.new("Frame")
FillVel.Parent = SliderVel
FillVel.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
FillVel.BorderSizePixel = 0
FillVel.Size = UDim2.new(0.25, 0, 1, 0)

local KnobVel = Instance.new("Frame")
KnobVel.Parent = SliderVel
KnobVel.BackgroundColor3 = Color3.fromRGB(180, 255, 180)
KnobVel.BorderSizePixel = 0
KnobVel.Size = UDim2.new(0, 16, 0, 16)
KnobVel.Position = UDim2.new(0.25, -8, 0, -4)

local CantoKnobV = Instance.new("UICorner")
CantoKnobV.CornerRadius = UDim.new(1, 0)
CantoKnobV.Parent = KnobVel

-- ==================== SLIDER FORÇA ====================
local LabelForca = Instance.new("TextLabel")
LabelForca.Parent = Area
LabelForca.BackgroundTransparency = 1
LabelForca.Position = UDim2.new(0, 0, 0, 232)
LabelForca.Size = UDim2.new(1, 0, 0, 20)
LabelForca.Font = Enum.Font.Gotham
LabelForca.Text = "Força do Arremesso: 250"
LabelForca.TextColor3 = Color3.fromRGB(255, 200, 200)
LabelForca.TextSize = 12
LabelForca.TextXAlignment = Enum.TextXAlignment.Left

local SliderForca = Instance.new("Frame")
SliderForca.Parent = Area
SliderForca.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
SliderForca.BorderSizePixel = 0
SliderForca.Position = UDim2.new(0, 0, 0, 255)
SliderForca.Size = UDim2.new(1, 0, 0, 8)

local FillForca = Instance.new("Frame")
FillForca.Parent = SliderForca
FillForca.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
FillForca.BorderSizePixel = 0
FillForca.Size = UDim2.new(0.5, 0, 1, 0)

local KnobForca = Instance.new("Frame")
KnobForca.Parent = SliderForca
KnobForca.BackgroundColor3 = Color3.fromRGB(255, 180, 180)
KnobForca.BorderSizePixel = 0
KnobForca.Size = UDim2.new(0, 16, 0, 16)
KnobForca.Position = UDim2.new(0.5, -8, 0, -4)

local CantoKnobF = Instance.new("UICorner")
CantoKnobF.CornerRadius = UDim.new(1, 0)
CantoKnobF.Parent = KnobForca

-- ==================== BOTÃO ARREMESSAR ====================
local BotaoArremessar = Instance.new("TextButton")
BotaoArremessar.Parent = Area
BotaoArremessar.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
BotaoArremessar.BorderSizePixel = 0
BotaoArremessar.Position = UDim2.new(0, 0, 0, 282)
BotaoArremessar.Size = UDim2.new(1, 0, 0, 45)
BotaoArremessar.Font = Enum.Font.GothamBold
BotaoArremessar.Text = "💥 ARREMESSAR BLOCO"
BotaoArremessar.TextColor3 = Color3.fromRGB(255, 255, 255)
BotaoArremessar.TextSize = 14

local CantoArrem = Instance.new("UICorner")
CantoArrem.CornerRadius = UDim.new(0, 6)
CantoArrem.Parent = BotaoArremessar

-- ==================== BOTÃO SOLTAR ====================
local BotaoSoltar = Instance.new("TextButton")
BotaoSoltar.Parent = Area
BotaoSoltar.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
BotaoSoltar.BorderSizePixel = 0
BotaoSoltar.Position = UDim2.new(0, 0, 0, 335)
BotaoSoltar.Size = UDim2.new(1, 0, 0, 35)
BotaoSoltar.Font = Enum.Font.GothamBold
BotaoSoltar.Text = "✋ Soltar Bloco"
BotaoSoltar.TextColor3 = Color3.fromRGB(255, 255, 255)
BotaoSoltar.TextSize = 13

local CantoSoltar = Instance.new("UICorner")
CantoSoltar.CornerRadius = UDim.new(0, 6)
CantoSoltar.Parent = BotaoSoltar

-- ==================== STATUS ====================
local LabelStatus = Instance.new("TextLabel")
LabelStatus.Parent = Area
LabelStatus.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
LabelStatus.BorderSizePixel = 0
LabelStatus.Position = UDim2.new(0, 0, 0, 382)
LabelStatus.Size = UDim2.new(1, 0, 0, 40)
LabelStatus.Font = Enum.Font.Gotham
LabelStatus.Text = "Status: Parado | Blocos: 0"
LabelStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
LabelStatus.TextSize = 12
LabelStatus.TextWrapped = true

local CantoStatus = Instance.new("UICorner")
CantoStatus.CornerRadius = UDim.new(0, 4)
CantoStatus.Parent = LabelStatus

-- ==================== ARRASTAR JANELA ====================
local arrastando = false
local inicioArraste, posInicial

BarraTitulo.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        arrastando = true
        inicioArraste = input.Position
        posInicial = Janela.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if arrastando and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - inicioArraste
        Janela.Position = UDim2.new(posInicial.X.Scale, posInicial.X.Offset + delta.X, posInicial.Y.Scale, posInicial.Y.Offset + delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        arrastando = false
    end
end)

-- ==================== MINIMIZAR ====================
local minimizado = false
local tamOriginal = UDim2.new(0, 280, 0, 440)
local tamMin = UDim2.new(0, 280, 0, 40)

BotaoMin.MouseButton1Click:Connect(function()
    minimizado = not minimizado
    local alvo = minimizado and tamMin or tamOriginal
    TweenService:Create(Janela, TweenInfo.new(0.25), {Size = alvo}):Play()
    Area.Visible = not minimizado
    BotaoMin.Text = minimizado and "+" or "—"
end)

BotaoFechar.MouseButton1Click:Connect(function()
    CONFIG.Ativado = false
    CONFIG.TelecineseAtiva = false
    limparTudo()
    soltarBlocoTelecinese()
    ScreenGui:Destroy()
end)

-- ==================== SLIDERS ====================
local function configurarSlider(slider, fill, knob, minV, maxV, passo, callback)
    local arrastandoS = false
    local function atualizar(inputX)
        local relX = inputX - slider.AbsolutePosition.X
        local pct = math.clamp(relX / slider.AbsoluteSize.X, 0, 1)
        local valor = minV + (maxV - minV) * pct
        valor = math.floor(valor / passo) * passo
        valor = math.clamp(valor, minV, maxV)
        local novoPct = (valor - minV) / (maxV - minV)
        fill.Size = UDim2.new(novoPct, 0, 1, 0)
        knob.Position = UDim2.new(novoPct, -8, 0, -4)
        callback(valor)
    end
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            arrastandoS = true
            atualizar(input.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if arrastandoS and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            atualizar(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            arrastandoS = false
        end
    end)
end

configurarSlider(SliderDist, FillDist, KnobDist, CONFIG.MinValor, CONFIG.MaxValor, CONFIG.Passo, function(v)
    CONFIG.Distancia = v
    LabelDist.Text = "Distância (Ímã): " .. v
end)

configurarSlider(SliderVel, FillVel, KnobVel, CONFIG.MinValor, CONFIG.MaxValor, CONFIG.Passo, function(v)
    CONFIG.Velocidade = v
    LabelVel.Text = "Velocidade (Ímã): " .. v
end)

configurarSlider(SliderForca, FillForca, KnobForca, 50, 500, 10, function(v)
    CONFIG.ForcaArremesso = v
    LabelForca.Text = "Força do Arremesso: " .. v
end)

-- ==================== FUNÇÕES BASE ====================
local function obterPersonagem()
    local c = player.Character
    if c then return c:FindFirstChild("HumanoidRootPart") end
    return nil
end

local function ehPersonagem(obj)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and obj:IsDescendantOf(p.Character) then
            return true
        end
    end
    return false
end

-- ⚠️ CORREÇÃO DO ABISMO: Só aceita blocos NÃO ancorados
-- Chão, paredes fixas, construções ancoradas → IGNORADOS
local function ehBlocoValido(obj)
    if not obj or not obj.Parent then return false end
    if not obj:IsA("BasePart") then return false end
    if obj:IsA("Terrain") then return false end
    if obj.Anchored then return false end -- ⚠️ ESSENCIAL: ignora ancorados
    if ehPersonagem(obj) then return false end
    if obj:FindFirstAncestorOfClass("Tool") then return false end
    if obj:FindFirstAncestorOfClass("Accessory") then return false end
    
    -- Ignora partes gigantes (mais de 200 studs em qualquer eixo)
    local tam = obj.Size
    if tam.X > 200 or tam.Y > 200 or tam.Z > 200 then
        return false
    end
    
    return true
end

function limparTudo()
    for parte, dados in pairs(partesControladas) do
        if parte and parte.Parent then
            if dados.giro then pcall(function() dados.giro:Destroy() end) end
            if dados.velocidade then pcall(function() dados.velocidade:Destroy() end) end
            pcall(function() parte:SetNetworkOwner(nil) end)
        end
    end
    partesControladas = {}
    for _, c in pairs(conexoes) do
        pcall(function() c:Disconnect() end)
    end
    conexoes = {}
end

-- ==================== ÍMÃ DE BLOCOS ====================
local function controlarParte(parte)
    if not parte or not parte.Parent or partesControladas[parte] then return end
    if not parte:IsA("BasePart") then return end
    if parte.Anchored then return end -- segurança extra
    
    local raiz = obterPersonagem()
    if not raiz then return end
    
    pegarOwnership(parte)
    
    local ancoradoOrig = parte.Anchored
    local cframeOrig = parte.CFrame
    
    parte.Anchored = false
    parte.CanCollide = false
    
    local giro = Instance.new("BodyGyro")
    giro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    giro.P = 50000
    giro.D = 500
    giro.CFrame = parte.CFrame
    giro.Parent = parte
    
    local velocidade = Instance.new("BodyVelocity")
    velocidade.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    velocidade.Velocity = Vector3.new(0, 0, 0)
    velocidade.Parent = parte
    
    partesControladas[parte] = {
        ancoradoOriginal = ancoradoOrig,
        cframeOriginal = cframeOrig,
        giro = giro,
        velocidade = velocidade
    }
    
    local conn = RunService.Heartbeat:Connect(function()
        if not CONFIG.Ativado then return end
        if not parte or not parte.Parent then return end
        
        local raizAtual = obterPersonagem()
        if not raizAtual then return end
        
        local minhaPos = raizAtual.Position
        local posParte = parte.Position
        local distancia = (minhaPos - posParte).Magnitude
        
        if distancia <= CONFIG.Distancia and distancia > 5 then
            local direcao = (minhaPos - posParte).Unit
            velocidade.Velocity = direcao * CONFIG.Velocidade
        elseif distancia <= 5 then
            velocidade.Velocity = Vector3.new(0, 0, 0)
        else
            velocidade.Velocity = Vector3.new(0, 0, 0)
        end
        
        giro.CFrame = giro.CFrame * CFrame.Angles(0, math.rad(CONFIG.Velocidade), 0)
    end)
    
    conexoes[parte] = conn
end

local function escanear()
    local raiz = obterPersonagem()
    if not raiz then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if ehBlocoValido(obj) and not partesControladas[obj] then
            local d = (obj.Position - raiz.Position).Magnitude
            if d <= CONFIG.Distancia then
                controlarParte(obj)
            end
        end
    end
end

-- ==================== TELECINESE ====================
local blocoTele = nil
local dadosTele = nil
local conexaoTele = nil
local toqueConnTele = nil

local function soltarBlocoTelecinese()
    if blocoTele and blocoTele.Parent then
        if dadosTele then
            if dadosTele.giro then pcall(function() dadosTele.giro:Destroy() end) end
            if dadosTele.velocidade then pcall(function() dadosTele.velocidade:Destroy() end) end
        end
        pcall(function() blocoTele:SetNetworkOwner(nil) end)
    end
    if conexaoTele then pcall(function() conexaoTele:Disconnect() end) end
    if toqueConnTele then pcall(function() toqueConnTele:Disconnect() end) end
    blocoTele = nil
    dadosTele = nil
    conexaoTele = nil
    toqueConnTele = nil
    CONFIG.BlocoTelecinese = nil
    
    LabelStatus.Text = "🧠 Telecinese: aguardando clique"
    LabelStatus.TextColor3 = Color3.fromRGB(180, 180, 255)
end

local function pegarBlocoComTelecinese(bloco)
    if not bloco or not bloco:IsA("BasePart") then return end
    if bloco.Anchored then
        LabelStatus.Text = "❌ Bloco ancorado! Escolha outro"
        LabelStatus.TextColor3 = Color3.fromRGB(255, 150, 150)
        return
    end
    if ehPersonagem(bloco) then
        LabelStatus.Text = "❌ Isso é um jogador!"
        LabelStatus.TextColor3 = Color3.fromRGB(255, 150, 150)
        return
    end
    
    soltarBlocoTelecinese()
    blocoTele = bloco
    CONFIG.BlocoTelecinese = bloco
    
    pegarOwnership(bloco)
    bloco.Anchored = false
    bloco.CanCollide = false
    
    local giro = Instance.new("BodyGyro")
    giro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    giro.P = 50000
    giro.D = 500
    giro.CFrame = bloco.CFrame
    giro.Parent = bloco
    
    local velocidade = Instance.new("BodyVelocity")
    velocidade.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    velocidade.Velocity = Vector3.new(0, 0, 0)
    velocidade.Parent = bloco
    
    dadosTele = { giro = giro, velocidade = velocidade }
    
    -- Conexão que faz o bloco seguir o dedo/mouse do jogador
    conexaoTele = RunService.Heartbeat:Connect(function()
        if not CONFIG.TelecineseAtiva or not blocoTele or not blocoTele.Parent then return end
        
        local raiz = obterPersonagem()
        if not raiz then return end
        
        -- Pega a posição do mouse (no PC) ou do toque (no celular)
        local camera = workspace.CurrentCamera
        local mousePos = UIS:GetMouseLocation()
        local raio = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
        
        -- Faz o bloco seguir o ponto do mundo onde o mouse aponta
        -- Fica a CONFIG.DistanciaFrente studs à frente do personagem
        local destino = raio.Origin + raio.Direction * CONFIG.DistanciaFrente
        
        -- Mantém uma altura fixa acima do chão (evita cair no abismo)
        destino = Vector3.new(destino.X, raiz.Position.Y + CONFIG.AlturaTelecinese, destino.Z)
        
        local direcao = (destino - blocoTele.Position)
        local distancia = direcao.Magnitude
        
        if distancia > 1 then
            velocidade.Velocity = direcao.Unit * math.min(distancia * 15, 200)
        else
            velocidade.Velocity = Vector3.new(0, 0, 0)
        end
        
        -- Gira o bloco no ar
        giro.CFrame = giro.CFrame * CFrame.Angles(0, math.rad(5), 0)
    end)
    
    LabelStatus.Text = "🧠 Segurando bloco! Mova o mouse"
    LabelStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
end

-- ==================== ATIVAR TELECINESE ====================
BotaoTele.MouseButton1Click:Connect(function()
    CONFIG.TelecineseAtiva = not CONFIG.TelecineseAtiva
    
    if CONFIG.TelecineseAtiva then
        BotaoTele.Text = "🧠 TELECINESE ATIVA (clique em bloco)"
        BotaoTele.BackgroundColor3 = Color3.fromRGB(120, 80, 220)
        Titulo.Text = "Telecinese [SELECIONAR]"
        Titulo.TextColor3 = Color3.fromRGB(180, 180, 255)
        LabelStatus.Text = "🧠 Clique em um bloco solto"
        LabelStatus.TextColor3 = Color3.fromRGB(180, 180, 255)
        
        -- Cria uma conexão para detectar cliques em blocos
        task.spawn(function()
            while CONFIG.TelecineseAtiva and ScreenGui and ScreenGui.Parent do
                task.wait(0.1)
                if not CONFIG.TelecineseAtiva then break end
                
                -- Detecta clique (toque no Android / mouse no PC)
                local inputDetected = false
                local pontoClique = nil
                
                -- Usa o InputBegan para pegar o clique/toque
                local connTemp
                connTemp = UIS.InputBegan:Connect(function(input, processado)
                    if processado then return end
                    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                        pontoClique = input.Position
                        inputDetected = true
                    end
                end)
                
                task.wait(0.05)
                if connTemp then connTemp:Disconnect() end
                
                if inputDetected and pontoClique then
                    local camera = workspace.CurrentCamera
                    local raio = camera:ViewportPointToRay(pontoClique.X, pontoClique.Y)
                    
                    local parametros = RaycastParams.new()
                    parametros.FilterType = Enum.RaycastFilterType.Exclude
                    parametros.FilterDescendantsInstances = {player.Character}
                    
                    local resultado = workspace:Raycast(raio.Origin, raio.Direction * 500, parametros)
                    
                    if resultado and resultado.Instance then
                        local bloco = resultado.Instance
                        if ehBlocoValido(bloco) then
                            pegarBlocoComTelecinese(bloco)
                            CONFIG.TelecineseAtiva = false
                            BotaoTele.Text = "🧠 LIBERAR TELECINESE"
                            BotaoTele.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
                            Titulo.Text = "Telecinese [ATIVA]"
                            Titulo.TextColor3 = Color3.fromRGB(100, 255, 100)
                            break
                        else
                            LabelStatus.Text = "❌ Bloco inválido, tente outro"
                            LabelStatus.TextColor3 = Color3.fromRGB(255, 150, 150)
                        end
                    end
                end
            end
        end)
    else
        BotaoTele.Text = "🧠 ATIVAR TELECINESE"
        BotaoTele.BackgroundColor3 = Color3.fromRGB(80, 60, 160)
        Titulo.Text = "Telecinese [DESLIGADO]"
        Titulo.TextColor3 = Color3.fromRGB(255, 100, 100)
        soltarBlocoTelecinese()
    end
end)

-- ==================== ARREMESSAR ====================
local function arremessarNasPessoas()
    local raiz = obterPersonagem()
    if not raiz then return end
    
    -- Se tem bloco na telecinese, arremessa ele
    if blocoTele and blocoTele.Parent and dadosTele then
        local alvos = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChild("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    table.insert(alvos, {hrp = hrp, hum = hum})
                end
            end
        end
        
        if #alvos == 0 then
            LabelStatus.Text = "⚠️ Nenhum jogador por perto"
            LabelStatus.TextColor3 = Color3.fromRGB(255, 180, 100)
            return
        end
        
        -- Acha o alvo mais próximo
        local alvoProximo = nil
        local menorD = math.huge
        for _, a in ipairs(alvos) do
            local d = (a.hrp.Position - blocoTele.Position).Magnitude
            if d < menorD then
                menorD = d
                alvoProximo = a
            end
        end
        
        pegarOwnership(blocoTele)
        
        local direcao = (alvoProximo.hrp.Position - blocoTele.Position).Unit
        
        if dadosTele.velocidade then
            dadosTele.velocidade.Velocity = direcao * CONFIG.ForcaArremesso + Vector3.new(0, 20, 0)
        end
        
        -- Dano por contato
        if toqueConnTele then toqueConnTele:Disconnect() end
        toqueConnTele = blocoTele.Touched:Connect(function(hit)
            local hum = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
            if hum and hum.Parent ~= player.Character then
                hum:TakeDamage(CONFIG.DanoArremesso)
                if toqueConnTele then toqueConnTele:Disconnect() end
            end
        end)
        
        LabelStatus.Text = "💥 Bloco arremessado!"
        LabelStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
        
        -- Solta depois de 3 segundos
        task.delay(3, function()
            soltarBlocoTelecinese()
            CONFIG.TelecineseAtiva = false
            BotaoTele.Text = "🧠 ATIVAR TELECINESE"
            BotaoTele.BackgroundColor3 = Color3.fromRGB(80, 60, 160)
            Titulo.Text = "Telecinese [DESLIGADO]"
            Titulo.TextColor3 = Color3.fromRGB(255, 100, 100)
        end)
    else
        LabelStatus.Text = "❌ Nenhum bloco na telecinese"
        LabelStatus.TextColor3 = Color3.fromRGB(255, 150, 150)
    end
end

BotaoArremessar.MouseButton1Click:Connect(arremessarNasPessoas)

-- ==================== SOLTAR ====================
BotaoSoltar.MouseButton1Click:Connect(function()
    soltarBlocoTelecinese()
    CONFIG.TelecineseAtiva = false
    BotaoTele.Text = "🧠 ATIVAR TELECINESE"
    BotaoTele.BackgroundColor3 = Color3.fromRGB(80, 60, 160)
    Titulo.Text = "Telecinese [DESLIGADO]"
    Titulo.TextColor3 = Color3.fromRGB(255, 100, 100)
end)

-- ==================== STATUS ====================
local function atualizarStatus()
    local c = 0
    for p in pairs(partesControladas) do
        if p and p.Parent then c = c + 1 end
    end
    if CONFIG.Ativado then
        LabelStatus.Text = string.format("Status: ATIVO | Blocos: %d", c)
        LabelStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
    elseif blocoTele then
        LabelStatus.Text = "🧠 Telecinese ativa (bloco na mão)"
        LabelStatus.TextColor3 = Color3.fromRGB(180, 180, 255)
    else
        LabelStatus.Text = "Status: Parado | Blocos: 0"
        LabelStatus.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end

-- ==================== BOTÃO ÍMÃ ====================
BotaoIma.MouseButton1Click:Connect(function()
    CONFIG.Ativado = not CONFIG.Ativado
    if CONFIG.Ativado then
        BotaoIma.Text = "Ímã de Blocos: LIGADO"
        BotaoIma.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
        escanear()
    else
        BotaoIma.Text = "Ímã de Blocos: DESLIGADO"
        BotaoIma.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        limparTudo()
    end
    atualizarStatus()
end)

task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        task.wait(1)
        if CONFIG.Ativado then escanear() end
        atualizarStatus()
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    if CONFIG.Ativado then
        limparTudo()
        escanear()
    end
end)

print("[Telecinese] GUI carregada com sucesso!")
