QBCore = exports['qb-core']:GetCoreObject()

local posizioni = Config.Positions -- Ensure 'Config.Positions' contains mailbox positions

local QBcore = nil
local mailboxTitle = ""
local guiEnabled = false
local props = {}

-- QB-Core
Citizen.CreateThread(function()
    while QBcore == nil do
        TriggerEvent('qb-core:GetObject', function(obj) QBcore = obj end)
        Citizen.Wait(0)
    end
end)

-- Function to spawn mailbox props and store references
Citizen.CreateThread(function()
    for k, v in pairs(posizioni) do
        QBCore.Functions.SpawnObject('prop_postbox_01a', vector3(v.x, v.y, v.z), function(obj)
            PlaceObjectOnGroundProperly(obj)
            FreezeEntityPosition(obj, true)
            SetEntityHeading(obj, v.h)
            table.insert(props, obj)
        end)
    end
end)

-- Resource stop event handler to delete mailbox props
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for k, v in pairs(props) do
            QBCore.Functions.DeleteObject(v)
        end
    end
end)

-- Main loop logic for mailbox interaction
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local plyCoords = GetEntityCoords(PlayerPedId(), false)
        for k, v in pairs(posizioni) do
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, v.x, v.y, v.z)
            if dist <= 1.2 then
                QBCore.ShowHelpNotification('Press ~INPUT_CONTEXT~ to interact') -- Replace with the relevant QB-Core notification message
                if IsControlJustPressed(1, 51) then -- Replace '51' with the QB-Core equivalent key code
                    QBCore.TriggerServerCallback('qb-core:mailbox:getTitle', function(titleResult)
                        QBCore.TriggerServerCallback('qb-core:mailbox:getMailCount', function(countResult)
                            QBCore.TriggerServerCallback('qb-core:mailbox:getUnreadCount', function(unreadResult)
                                QBCore.TriggerServerCallback('qb-core:mailbox:hasItem', function(gotItem)
                                    local mailboxTitle = titleResult or 'Mailbox Undefined'
                                    OpenMailboxInterface(gotItem, unreadResult, countResult, mailboxTitle)
                                end, v.itemname)
                            end, v.dbid)
                        end, v.dbid)
                    end, v.dbid)
                end
            end
        end
    end
end)

function OpenMailboxInterface(hasItem, unreadCount, totalCount, mailboxTitle)
    -- Handle mailbox opening and interaction here using QB-Core UI or any other implementation.
    -- This function would open the mailbox interface with the provided data.
end

function EnableGui(enable, mailid, mailtitle, mailtext, mailfooter, maildata, mailautor)
    SetNuiFocus(enable, enable)
    guiEnabled = enable

    SendNUIMessage({
        type = "enableui",
        enable = enable,
        mailid = mailid,
        mailtitle = mailtitle,
        mailtext = mailtext,
        mailfooter = mailfooter,
        maildata = maildata,
        mailautor = mailautor
    })
end

function EditMailbox()
    QBCore.UI.Menu.CloseAll()

    QBCore.UI.Menu.Open('dialog', GetCurrentResourceName(), 'edit_mailbox', {
        title = 'Edit Mailbox' -- Replace with your localized title
    }, function(data, menu)
        for k, v in pairs(posizioni) do
            local plyCoords = GetEntityCoords(PlayerPedId(), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, v.x, v.y, v.z)
            if dist <= 1.2 then
                menu.close()
                QBCore.TriggerServerCallback('qb-core:mailbox:setTitle', function(response)
                    QBCore.ShowNotification('Mailbox changes successfully: ' .. data.value) -- Replace with your notification message
                end, data.value, v.mailboxId)
            end
        end
    end, function(data, menu)
        menu.close()
    end)
end

function SendMail()
    QBCore.UI.Menu.CloseAll()

    QBCore.UI.Menu.Open('dialog', GetCurrentResourceName(), 'send_title', {
        title = 'Mail Subject' -- Replace with your localized title
    }, function(data, menu)
        QBCore.UI.Menu.CloseAll()
        QBCore.UI.Menu.Open('dialog', GetCurrentResourceName(), 'send_main', {
            title = 'Mail Content' -- Replace with your localized title
        }, function(data2, menu2)
            QBCore.UI.Menu.Open('dialog', GetCurrentResourceName(), 'send_footer', {
                title = 'Mail Footer' -- Replace with your localized title
            }, function(data3, menu3)
                QBCore.UI.Menu.CloseAll()
                QBCore.UI.Menu.Open('dialog', GetCurrentResourceName(), 'send_sender', {
                    title = 'Mail Author' -- Replace with your localized title
                }, function(data4, menu4)
                    QBCore.UI.Menu.CloseAll()
                    for k, v in pairs(posizioni) do
                        local plyCoords = GetEntityCoords(PlayerPedId(), false)
                        local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, v.x, v.y, v.z)
                        if dist <= 1.2 then
                            QBCore.TriggerServerEvent('qb-core:mailbox:addMail', data.value, data2.value, data3.value, data4.value, v.mailboxId)
                        end
                    end
                end, function(data4, menu4)
                    QBCore.UI.Menu.CloseAll()
                end)
            end, function(data3, menu3)
                QBCore.UI.Menu.CloseAll()
            end)
        end, function(data2, menu2)
            QBCore.UI.Menu.CloseAll()
        end)
    end, function(data, menu)
        QBCore.UI.Menu.CloseAll()
    end)
end

function GetMail()
    for k, v in pairs(posizioni) do
        local plyCoords = GetEntityCoords(PlayerPedId(), false)
        local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, v.x, v.y, v.z)
        if dist <= 1.2 then
            QBCore.TriggerServerCallback('qb-core:mailbox:getMail', function(mails)
                local elements = {}
                for k, mail in pairs(mails) do
                    table.insert(elements, {label = mail.id .. ' - ' .. mail.title, id = mail.id, title = mail.title, text = mail.text, footer = mail.footer, data = mail.data, autor = mail.autor, unread = mail.unread})
                end
                QBCore.UI.Menu.Open('default', GetCurrentResourceName(), 'mailbox_show', {
                    title = 'Mailbox Inbox', -- Replace with your localized title
                    align = 'top-left',
                    elements = elements
                }, function(data, menu)
                    local elements2 = {
                        {label = 'Read', value = 'show'},
                        {label = 'Mark Read', value = 'read'},
                        {label = 'Mark Unread', value = 'unread'},
                        {label = 'Delete', value = 'delete'}
                    }
                    QBCore.UI.Menu.Open('default', GetCurrentResourceName(), 'mailbox_options', {
                        title = 'Mailbox Options', -- Replace with your localized title
                        align = 'top-left',
                        elements = elements2
                    }, function(data2, menu2)
                        if data2.current.value == 'show' then
                            QBCore.UI.Menu.CloseAll()
                            EnableGui(true, data.current.id, data.current.title, data.current.text, data.current.footer, data.current.data, data.current.autor)
                        elseif data2.current.value == 'read' then
                            QBCore.TriggerServerEvent('qb-core:mailbox:setRead', data.current.id)
                        elseif data2.current.value == 'unread' then
                            QBCore.TriggerServerEvent('qb-core:mailbox:setUnread', data.current.id)
                        elseif data2.current.value == 'delete' then
                            QBCore.TriggerServerEvent('qb-core:mailbox:delete', data.current.id)
                        end
                    end, function(data2, menu2)
                        menu2.close()
                        EnableGui(false, data.current.id, data.current.title, data.current.text, data.current.footer, data.current.data, data.current.autor)
                    end)
                end, function(data, menu)
                    menu.close()
                    EnableGui(false, data.current.id, data.current.title, data.current.text, data.current.footer, data.current.data, data.current.autor)
                end)
            end, v.mailboxId)
        end
    end
end

function OpenMailboxInterface(isOwner, unread, total, title, canOpen)
    local elements = {
        {label = 'Send Mail', value = 'send'}
    }
    if isOwner then
        table.insert(elements, {label = 'Check Mail (' .. unread .. '/' .. total .. ')', value = 'get'})
        table.insert(elements, {label = 'Edit Name', value = 'edit'})
    end
    QBCore.UI.Menu.CloseAll()
    QBCore.UI.Menu.Open('default', GetCurrentResourceName(), 'mailbox_main', {
        title = title,
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        if data.current.value == 'edit' then
            EditMailbox()
        elseif data.current.value == 'get' then
            GetMail()
        elseif data.current.value == 'send' then
            SendMail()
        end
    end, function(data, menu)
        menu.close()
    end)
end

function CloseGui()
    SetNuiFocus(false, false)
    SendNUIMessage({type = "enableui", enable = false})
end

RegisterNUICallback('quit', function(data, cb)
    CloseGui()
    cb('ok')
end)

function ConvertDate(vardate)
    local y, m, d = string.match(vardate, '(%d+)-(%d+)-(%d+)')
    return string.format('%s-%s-%s', y, m, d)
end

-- 3d Text Function
DrawText3Ds = function(coords, text, scale)
    local x, y, z = coords.x, coords.y, coords.z
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextEntry("STRING")
        SetTextCentre(1)
        SetTextColour(255, 255, 255, 215)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 280
    end
end
