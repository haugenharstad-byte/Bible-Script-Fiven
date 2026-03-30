Config = Config or {}

Config.ItemName = 'bible'
Config.ItemLabel = 'Holy Bible'

Config.EnableOxInventoryUse = true
Config.EnableQBCoreUsableItem = true
Config.EnableOxTarget = true

Config.EnableCommand = false
Config.CommandName = 'bible'

Config.Animation = {
    dict = 'amb@world_human_clipboard@male@idle_a',
    clip = 'idle_c',
    flag = 49,
    prop = 'prop_cs_book_01',
    bone = 60309,
    position = vec3(0.13, 0.01, 0.02),
    rotation = vec3(10.0, 0.0, -8.0)
}

Config.Ui = {
    title = 'Holy Bible',
    subtitle = 'Thirty verses for peace, courage, rest, and hope.',
    footer = 'Be still, and know that I am God.',
    translation = 'KJV'
}

Config.TargetModelLabel = 'Read the Bible'
Config.TargetModelDistance = 2.0

Config.TargetModels = {
    -- Replace this with your actual bible prop model or hash.
    -- 'your_bible_prop',
}

Config.TargetZones = {
    -- {
    --     coords = vec3(315.89, -595.05, 43.29),
    --     size = vec3(1.2, 1.2, 2.0),
    --     rotation = 340.0,
    --     distance = 2.0,
    --     label = 'Read the Bible',
    --     icon = 'fa-solid fa-book-bible',
    --     drawSprite = true,
    --     debug = false
    -- }
}
