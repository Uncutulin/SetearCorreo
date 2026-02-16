local addonName, ns = ...

-- SLASH COMMAND
SLASH_SETEARCORREO1 = "/setearcorreo"
SLASH_SETEARCORREO2 = "/sc"
SlashCmdList["SETEARCORREO"] = function()
   print("SetearCorreo ahora está integrado en el correo.")
end

-- EVENT FRAME (CORE)
local f = CreateFrame("Frame")
f:RegisterEvent("MAIL_SHOW")
f:RegisterEvent("MAIL_CLOSED")

f:SetScript("OnEvent", function(self, event)
    if event == "MAIL_SHOW" then
        -- Crear panel UI si no existe
        if not ns.UI or not ns.UI.frame then
            ns.CreateMainPanel()
        end
        
        -- Integración en SendMailFrame
        if not self.integrated and SendMailFrame then
             ns.UI.frame:SetParent(SendMailFrame)
             ns.UI.frame:SetPoint("TOPLEFT", SendMailFrame, "TOPRIGHT", -40, -20)
             
             -- Crear botón Toggle
             ns.CreateToggleButton()
             
             -- Configurar AUTOCOMPLETADO (Lógica Robusta de Core)
             local input = ns.input
             if input then
                 local copiado = false
                 if _G.SendMailNameEditBox and _G.SendMailNameEditBox.autoCompleteSource then
                     -- Copiar configuración oficial
                     input.autoCompleteSource = _G.SendMailNameEditBox.autoCompleteSource
                     input.autoCompleteParams = _G.SendMailNameEditBox.autoCompleteParams
                     input.autoCompleteContext = _G.SendMailNameEditBox.autoCompleteContext or "MAIL"
                     copiado = true
                 end
                 
                 -- Fallback manual
                 if not copiado then
                     -- Flags hardcoded: 1+2+4+8+16 = 31 
                     local includeMask = 31 
                     local excludeMask = 0
                     input.autoCompleteSource = GetAutoCompleteResults
                     input.autoCompleteParams = {20, 0, true, includeMask, excludeMask}
                     input.autoCompleteContext = "MAIL"
                 end
                 
                 input.addHighlightedText = true
                 input:SetScript("OnEnterPressed", EditBox_ClearFocus)
                 input:SetScript("OnEscapePressed", EditBox_ClearFocus)
             end
             
             self.integrated = true
        end
        
        ns.UI.frame:Show()
        
    elseif event == "MAIL_CLOSED" then
        if ns.UI and ns.UI.frame then
            ns.UI.frame:Hide()
        end
    end
end)
