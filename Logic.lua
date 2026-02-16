local addonName, ns = ...

-- Estado compartido
ns.selectedItemID = nil

-- Lógica: Enviar objetos al correo
function ns.EnviarObjetosAlCorreo()
    if not ns.selectedItemID then
        print("|cffff0000Error:|r No has seleccionado ningún objeto.")
        return
    end

    local ranurasAdjunto = {}
    for i = 1, ATTACHMENTS_MAX_SEND do
        local ranura = _G["SendMailAttachment" .. i]
        if ranura then
            table.insert(ranurasAdjunto, ranura)
        end
    end

    if #ranurasAdjunto <= 0 then return end

    local ranuraAdjuntoIndex = 1

    for bagID = 0, 4 do
        local numSlots = C_Container.GetContainerNumSlots(bagID)
        for slotID = 1, numSlots do
            if ranuraAdjuntoIndex > #ranurasAdjunto then
                return -- Todas las ranuras de adjunto están llenas
            end
            
            local containerInfo = C_Container.GetContainerItemInfo(bagID, slotID)
            -- Comprobamos si hay Info, si NO está bloqueado (ya enviado/usado) y si es el ID correcto
            if containerInfo and not containerInfo.isLocked and containerInfo.itemID == ns.selectedItemID then
                local ranura = ranurasAdjunto[ranuraAdjuntoIndex]
                if ranura then
                    -- Simular clic en el objeto en la bolsa
                    C_Container.PickupContainerItem(bagID, slotID)

                    -- Simular clic en la ranura de adjunto
                    ranura:Click()

                    ranuraAdjuntoIndex = ranuraAdjuntoIndex + 1
                end
            end
        end
    end
end

-- Lógica: Configurar Texto (Destinatario/Asunto)
function ns.ConfigurarCorreo()
    if not ns.input then return end
    
    local name = ns.input:GetText() 
    local text = "Armadura"
    if ns.selectedItemID then
        local itemName = GetItemInfo(ns.selectedItemID)
        if itemName then text = itemName end
    end
    
    if SendMailNameEditBox then SendMailNameEditBox:SetText(name) end
    if SendMailSubjectEditBox then SendMailSubjectEditBox:SetText(text) end
end

-- Lógica: Limpiar Datos
function ns.LimpiarDatos()
    if ns.input then ns.input:SetText("") end
    
    ns.selectedItemID = nil
    if ns.itemSlot and ns.itemSlot.icon then
        ns.itemSlot.icon:SetTexture(nil)
    end
    
    print("|cffffff00SetearCorreo:|r Datos limpiados.")
    
    -- Limpiar correo nativo
    ClearSendMail()
    
    if SendMailNameEditBox then SendMailNameEditBox:SetText("") end
    if SendMailSubjectEditBox then SendMailSubjectEditBox:SetText("") end
    if SendMailBodyEditBox then SendMailBodyEditBox:SetText("") end
end
