local addonName, ns = ...

-- Estado compartido
ns.selectedItemID = nil

-- Lógica: Enviar objetos al correo
function ns.EnviarObjetosAlCorreo()
    if not ns.selectedItemID then
        print("|cffff0000Error:|r No has seleccionado ningún objeto.")
        return
    end

    local itemsAttached = 0
    -- ATTACHMENTS_MAX_SEND usually is 12
    local maxAttachments = ATTACHMENTS_MAX_SEND or 12

    for bagID = 0, 5 do
        local numSlots = C_Container.GetContainerNumSlots(bagID)
        for slotID = 1, numSlots do
            if itemsAttached >= maxAttachments then
                return -- Ya hemos llenado los huecos permitidos
            end
            
            local containerInfo = C_Container.GetContainerItemInfo(bagID, slotID)
            
            -- Verificamos que el item sea el seleccionado y no esté bloqueado
            if containerInfo and not containerInfo.isLocked and containerInfo.itemID == ns.selectedItemID then
                
                -- UseContainerItem pone el objeto en el correo si la ventana de correo está abierta
                -- Esto maneja automáticamente los stacks y es más seguro que Pickup+Click
                C_Container.UseContainerItem(bagID, slotID)
                
                itemsAttached = itemsAttached + 1
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
    if ns.UI.itemSlot and ns.UI.itemSlot.icon then
        ns.UI.itemSlot.icon:SetTexture(nil)
    end
    
    print("|cffffff00SetearCorreo:|r Datos limpiados.")
    
    -- Limpiar correo nativo
    ClearSendMail()
    
    if SendMailNameEditBox then SendMailNameEditBox:SetText("") end
    if SendMailSubjectEditBox then SendMailSubjectEditBox:SetText("") end
    if SendMailBodyEditBox then SendMailBodyEditBox:SetText("") end
end
