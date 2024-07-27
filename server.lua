local QBCore = exports['qb-core']:GetCoreObject()
local mailData = {} -- Initialize an empty table to hold mail data

-- Loading the JSON file and setting it to mailData
local function loadMailData()
    local file = LoadResourceFile(GetCurrentResourceName(), 'mail.json')
    if file then
        -- Assign the loaded data to the mailData table
        mailData = json.decode(file)
    end
end

-- Function to save mailData to the JSON file
local function saveMailData()
    -- Save the current mailData to the JSON file
    SaveResourceFile(GetCurrentResourceName(), 'mail.json', json.encode(mailData, { indent = true }), -1)
end

loadMailData() -- Call to load mail data when the server starts

RegisterServerEvent('qb-core:mailbox:setTitle')
AddEventHandler('qb-core:mailbox:setTitle', function(title, identifier)
    if mailData[identifier] then
        mailData[identifier].title = title
        saveMailData() -- Save changes after updating title
    end
end)

RegisterServerEvent('qb-core:mailbox:addMail')
AddEventHandler('qb-core:mailbox:addMail', function(title, text, footer, autor, identifier)
    if not mailData[identifier] then mailData[identifier] = { mails = {} } end
    local currentDate = os.date("%Y-%m-%d")
    local newMail = {
        title = title,
        text = text,
        footer = footer,
        data = currentDate,
        autor = autor,
        unread = true -- Using boolean value for unread status
    }
    table.insert(mailData[identifier].mails, newMail)
    saveMailData() -- Save changes after adding new mail
end)

QBCore.Functions.CreateCallback('qb-core:mailbox:getUnreadCount', function(source, cb, identifier)
    if not mailData[identifier] then cb(0) return end
    local count = 0
    for _, mail in ipairs(mailData[identifier].mails) do
        if mail.unread then
            count = count + 1
        end
    end
    cb(count)
end)

QBCore.Functions.CreateCallback('qb-core:mailbox:getMailCount', function(source, cb, identifier)
    if not mailData[identifier] then cb(0) return end
    cb(#mailData[identifier].mails)
end)

QBCore.Functions.CreateCallback('qb-core:mailbox:getMail', function(source, cb, identifier)
    if not mailData[identifier] then cb({}) return end
    cb(mailData[identifier].mails or {})
end)

RegisterServerEvent('qb-core:mailbox:setRead')
AddEventHandler('qb-core:mailbox:setRead', function(id, identifier)
    if mailData[identifier] then
        for _, mail in ipairs(mailData[identifier].mails) do
            if mail.id == id then
                mail.unread = false
                break
            end
        end
        saveMailData() -- Save changes after marking mail as read
    end
end)

RegisterServerEvent('qb-core:mailbox:setUnread')
AddEventHandler('qb-core:mailbox:setUnread', function(id, identifier)
    if mailData[identifier] then
        for _, mail in ipairs(mailData[identifier].mails) do
            if mail.id == id then
                mail.unread = true
                break
            end
        end
        saveMailData() -- Save changes after marking mail as unread
    end
end)

RegisterServerEvent('qb-core:mailbox:delete')
AddEventHandler('qb-core:mailbox:delete', function(id, identifier)
    if mailData[identifier] then
        for i, mail in ipairs(mailData[identifier].mails) do
            if mail.id == id then
                table.remove(mailData[identifier].mails, i)
                break
            end
        end
        saveMailData() -- Save changes after deleting mail
    end
end)

QBCore.Functions.CreateCallback('qb-core:mailbox:hasItem', function(source, cb, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.GetItemByName(item) then
        cb(true)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('qb-core:mailbox:getTitle', function(source, cb, identifier)
    if mailData[identifier] then
        cb(mailData[identifier].title)
    else
        cb(nil)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Save mailData every minute
        saveMailData()
    end
end)
