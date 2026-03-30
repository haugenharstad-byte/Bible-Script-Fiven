inspiring_bible
A standalone FiveM resource with a custom Bible NUI for QBCore, ox_inventory, and ox_target.

Features
30 inspiring Bible verses built into a custom full-screen UI
Random verse on open, with previous, next, and shuffle buttons
ox_inventory item-use export for the bible item
QBCore.Functions.CreateUseableItem fallback
Optional ox_target box zones and model interactions
Reading animation with a held book prop while the UI is open
Install
Move the inspiring_bible folder into your FiveM resources directory.
Add ensure inspiring_bible to your server.cfg after qb-core, ox_inventory, and ox_target.
Put the bible item in ox_inventory/data/items.lua with the client export below.
If you want the QB usable-item fallback too, also add the item to qb-core/shared/items.lua.
Edit config.lua if you want ox_target zones or models.
/bible is disabled by default so the UI only opens from the item or your target interactions.

ox_inventory item
['bible'] = {
    label = 'Holy Bible',
    weight = 200,
    stack = false,
    close = true,
    consume = 0,
    description = 'A beautiful Bible filled with verses of hope and strength.',
    client = {
        export = 'inspiring_bible.bible'
    }
},
qb-core item
['bible'] = {
    name = 'bible',
    label = 'Holy Bible',
    weight = 200,
    type = 'item',
    image = 'bible.png',
    unique = true,
    useable = true,
    shouldClose = true,
    combinable = nil,
    description = 'A beautiful Bible filled with verses of hope and strength.'
},
ox_target
You can add one or more zones in config.lua:

Config.TargetZones = {
    {
        coords = vec3(315.89, -595.05, 43.29),
        size = vec3(1.2, 1.2, 2.0),
        rotation = 340.0,
        distance = 2.0,
        label = 'Read the Bible',
        icon = 'fa-solid fa-book-bible',
        drawSprite = true,
        debug = false
    }
}
Or use object models:

Config.TargetModels = {
    'your_bible_prop'
}
Animation
The reading animation and prop can be changed in config.lua under Config.Animation.
