local mailData = {
    identifier1 = {
        mails = {
            {
                id = 1,
                title = "Sample Title 1",
                text = "Sample Text 1",
                footer = "Sample Footer 1",
                date = "2023-12-27",
                author = "John Doe", -- Corrected from 'autor' to 'author'
                unread = 0,
                dbid = 1
            },
            {
                id = 2,
                title = "Sample Title 2",
                text = "Sample Text 2",
                footer = "Sample Footer 2",
                date = "2023-12-28",
                author = "Jane Doe", -- Corrected from 'autor' to 'author'
                unread = 1,
                dbid = 2
            },
            -- Add more mail items for identifier1
        }
    },
    identifier2 = {
        mails = {
            -- Mail items for identifier2
        }
    },
    -- Add more identifiers and mailboxes as needed
}

return mailData
