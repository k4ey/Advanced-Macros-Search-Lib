local Finder = require('finder')
log(Finder)
-- examples:
log(Finder.advancedSearch("all",Finder.checks.byAmount, {
    amount = 10,
    amountShouldBe = "equal"
}, true))


-- finds slots that have 10 items with id minecraft:dirt and name (case - insensitive) that contains word "podzo"
log(Finder.advancedSearch("all",{
    Finder.checks.byAmount, Finder.checks.byName, Finder.checks.byId
},
{
    amount = 10,
    amountShouldBe = "equal",

    name = "podzo",
    ignoreCase = true,

    id = "dirt",
    insertSuffix = true,

    exact = {
        byName = false,
        byId = true
    }
},
true))


-- finds slots inside of a shulkerbox that contain items with name that has "d" in them, id equal to "minecraft:dirt" and amount equal to 10
log(Finder.advancedShulkerSearch(openInventory().getSlot(10),
{
    Finder.checks.nbt.byName, Finder.checks.nbt.byId, Finder.checks.nbt.byAmount
},
{
    name = "d",
    ignoreCase = true,

    id = "dirt",
    insertSuffix = true,

    amount = 10,
    amountShouldBe = "equal",
    exact = {
        byName = false
    }
},true))

log(Finder.advancedSearch("all",{
    Finder.checks.byName, Finder.checks.byId, Finder.checks.byContainer
},
{
    name = "shalker",
    ignoreCase = true,

    id = "white_shulker_box",
    insertSuffix = true,


    containerArgs = {
        checkFunctions = {Finder.checks.nbt.byName, Finder.checks.nbt.byId, Finder.checks.nbt.byAmount}, -- containers should use nbt functions - they have different paths than normal items

        amountOfMatches = 3, -- just like byAmount but checks whether the amount of items with given criteria is inside the shulkerbox
        amountOfMatchesShouldBe = "equal",

        name = "podzol", -- this function will break most of the time, as items in shulkerboxes do not have names
        ignoreCase = true,

        id = "dirt",
        insertSuffix = true,

        amount = 10,
        amountShouldBe = "equal",

        exact = {
            byName = false
        }


    }

},true))


-- this will find all slots with items of id "minecraft:white_shulker_box" that have "shalker" declared as their name (ignores case), and inside of them are exactly 3 slots with 1 dirt block each called: "d"
log(Finder.advancedSearch("all",{
    Finder.checks.byName, Finder.checks.byId, Finder.checks.byContainer
},
{
    name = "shalker",
    ignoreCase = true,

    id = "white_shulker_box",
    insertSuffix = true,


    containerArgs = {
        checkFunctions = {Finder.checks.nbt.byName, Finder.checks.nbt.byId, Finder.checks.nbt.byAmount}, -- containers should use nbt functions - they have different paths than normal items

        amountOfMatches = 3, -- just like byAmount but checks whether the amount of items with given criteria is inside the shulkerbox
        amountOfMatchesShouldBe = "equal",

        name = "d", -- this function will break most of the time, as items in shulkerboxes do not have names
        ignoreCase = true,

        id = "dirt",
        insertSuffix = true,

        amount = 1,
        amountShouldBe = "equal",

        exact = {
            byName = false
        }


    }

},true))
