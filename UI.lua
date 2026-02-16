local addonName, ns = ...
ns.UI = {}

function ns.CreateMainPanel()
    -- Integración como PANEL LATERAL (Restaurando Autocompletado OFICIAL)
    local frame = CreateFrame("Frame", "MiAddonFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(170, 290)
    frame:Hide()
    ns.UI.frame = frame
    
    -- Título del panel
    frame.TitleText:SetText("Setear Correo")
    
    -- Ocultar el botón de cerrar nativo (la X)
    if _G["MiAddonFrameCloseButton"] then
        _G["MiAddonFrameCloseButton"]:Hide()
        _G["MiAddonFrameCloseButton"]:SetScript("OnShow", function(self) self:Hide() end)
    end
    
    -- 1. SLOT PARA ITEM (Arriba del todo) - MÁS GRANDE
    local itemSlot = CreateFrame("Button", "MiAddonItemSlot", frame)
    itemSlot:SetPoint("TOP", frame, "TOP", 0, -35)
    itemSlot:SetSize(92, 92) 
    ns.UI.itemSlot = itemSlot
    
    -- Añadir fondo/borde básico
    itemSlot:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
    itemSlot:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
    itemSlot:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    
    -- Añadir textura para el ICONO DEL ITEM
    itemSlot.icon = itemSlot:CreateTexture(nil, "ARTWORK")
    itemSlot.icon:SetSize(60, 60) 
    itemSlot.icon:SetPoint("CENTER")
    itemSlot.icon:SetTexture(nil) 
    
    -- Registrar clicks derecho e izquierdo
    itemSlot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    
    -- Etiqueta "Arrastra objeto"
    local slotLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slotLabel:SetPoint("TOP", itemSlot, "BOTTOM", 0, -5)
    slotLabel:SetText("Arrastra objeto")
    
    local helpLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    helpLabel:SetPoint("TOP", slotLabel, "BOTTOM", 0, -2)
    helpLabel:SetText("(Click Der. para borrar)")
    
    -- 2. INPUT DE TEXTO (Debajo del slot)
    local nameLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameLabel:SetPoint("TOP", helpLabel, "BOTTOM", 0, -15) 
    nameLabel:SetText("Para:")
    
    local input = CreateFrame("EditBox", "MiAddonInputBox", frame, "InputBoxTemplate, AutoCompleteEditBoxTemplate")
    input:SetSize(120, 20)
    input:SetPoint("TOP", nameLabel, "BOTTOM", -10, -5) 
    input:SetAutoFocus(false)
    input:SetMaxLetters(50)
    ns.input = input -- Guardamos referencia para Logic.lua
    
    -- Botón LIMPIAR (Escoba)
    local clearButton = CreateFrame("Button", nil, frame)
    clearButton:SetSize(20, 20)
    clearButton:SetPoint("LEFT", input, "RIGHT", 5, 0)
    clearButton:SetNormalTexture(655994)
    clearButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    clearButton:SetPushedTexture(655994)
    clearButton:GetPushedTexture():SetVertexColor(0.8, 0.8, 0.8) -- Darken when pushed-1)
    clearButton:SetScript("OnClick", function()
        ns.LimpiarDatos()
    end)
    
    -- Funcionalidad Drag & Drop Slot
    itemSlot:SetScript("OnReceiveDrag", function(self)
        local type, id, link = GetCursorInfo()
        if type == "item" then
            ns.selectedItemID = id
            local _, _, _, _, icon = GetItemInfoInstant(id)
            self.icon:SetTexture(icon)
            ClearCursor() 
            print("|cff00ff00SetearCorreo:|r Item: " .. link)
        end
    end)
    
    itemSlot:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            ns.LimpiarDatos()
            return
        end
    
        local type, id, link = GetCursorInfo()
        if type == "item" then
            ns.selectedItemID = id
            local _, _, _, _, icon = GetItemInfoInstant(id)
            self.icon:SetTexture(icon)
            ClearCursor()
            print("|cff00ff00SetearCorreo:|r Item: " .. link)
        else
            if not ns.selectedItemID then
                print("|cffffff00SetearCorreo:|r Arrastra un objeto aquí.")
            end
        end
    end)
    
    -- Tooltip Slot
    itemSlot:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if ns.selectedItemID then
            GameTooltip:SetItemByID(ns.selectedItemID)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Click Der. para quitar", 1, 0, 0)
        else
            GameTooltip:SetText("Arrastra un objeto aquí", 1, 1, 1)
        end
        GameTooltip:Show()
    end)
    
    itemSlot:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    -- 3. BOTÓN ENVIAR
    local sendButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    sendButton:SetSize(120, 25)
    sendButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 15) 
    sendButton:SetText("Enviar")
    sendButton:SetScript("OnClick", function()
        if SendMailMailButton:IsEnabled() then
            SendMailMailButton:Click()
        else
            print("|cffff0000SetearCorreo:|r Faltan datos para enviar (Destinatario/Asunto).")
        end
    end)
    
    -- BOTÓN AUTOLLENAR
    local button = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    button:SetSize(120, 25)
    button:SetPoint("BOTTOM", sendButton, "TOP", 0, 5) 
    button:SetText("Autollenar")
    button:SetScript("OnClick", function()    
        ns.EnviarObjetosAlCorreo()
        ns.ConfigurarCorreo()
    end)
end

function ns.CreateToggleButton()
     if ns.UI.toggleButton then return end

     local toggleBtn = CreateFrame("Button", "MiAddonToggleBtn", SendMailFrame, "UIPanelButtonTemplate")
     toggleBtn:SetSize(50, 20)
     toggleBtn:SetPoint("TOPRIGHT", SendMailFrame, "TOPRIGHT", 10, 0) 
     toggleBtn:SetFrameStrata("DIALOG") 
     toggleBtn:SetFrameLevel(900)
     
     toggleBtn:SetText("ST <<") 
     toggleBtn:SetScript("OnClick", function(btn)
         if ns.UI.frame:IsShown() then
             ns.UI.frame:Hide()
             btn:SetText("ST >>") 
         else
             ns.UI.frame:Show()
             btn:SetText("ST <<")
         end
     end)
     toggleBtn:Show()
     ns.UI.toggleButton = toggleBtn
     print("|cff00ff00SetearCorreo:|r Botón de ocultar cargado.")
end
