local inv = openInventory()
local Finder = {}
local utils = run("utils.lua")
Finder.mappings = run("mappings.lua")

Finder.checks = {}
Finder.checks.nbt = {}



-- <item> - item to check
-- <amount> - amount of items 
-- <amountShouldBe> - whether the amount of items should be: "equal", "less" or "more" than <amount>
function Finder.checks.byAmount(item --[[Item]], args --[[table]] )
    local amount = args.amount
    local amountShouldBe = args.amountShouldBe
    local amountIs = utils.compare(item.amount, amount) -- checks whether the amount of items is more/less/equal as amount

    return amountIs == amountShouldBe
end

-- <item> - item to check
-- <id> - id of the item
-- <insertSuffix> - every id has "minecraft:" suffix - should it be inserted?
-- <exact> - whether the id should be exact
function Finder.checks.byId(item --[[Item]], args --[[table]])
    local insertSuffix = args.insertSuffix
    local id = args.id
    local exact = args.exact
    if insertSuffix then id = "minecraft:" .. id end
    return utils.find( item.id, id ,exact)
end

-- <item> - item to check
-- <ignoreCase> - whether the check should be CaSe SenSitiVe
-- <exact> - whether the name should be exact
function Finder.checks.byName(item --[[Item]], args --[[table]])
    local ignoreCase = args.ignoreCase
    local exact = args.exact
    if ignoreCase then args.name = string.lower(args.name); item.name = string.lower(item.name)  end
    return utils.find( item.name, args.name, exact)
end

-- <item> - item to check
-- <ignoreCase> - whether the check should be CaSe SenSitiVe
-- <exact> - whether the name should be exact
-- this function only works if the item has a CUSTOM NAME, minecraft does not include normal names inside nbt data
function Finder.checks.nbt.byName(item --[[Item]], args --[[table]])
    if not item.tag or  not item.tag.display or not item.tag.display.Name then
        if not IGNORE_FINDER_WARNINGS then
            log(("&4%s does not have a name!&f this function works only on custom names, set IGNORE_FINDER_WARNINGS = true to disable this message"):format(item.id))
        end
        return false
    end

    local ignoreCase = args.ignoreCase
    local itemName = item.tag.display.Name
    local exact = args.exact

    if ignoreCase then args.name = string.lower(args.name); itemName = string.lower(itemName)  end
    return utils.find( itemName, args.name, exact)
end

Finder.checks.nbt.byId = Finder.checks.byId

-- <item> - item to check
-- <amount> - amount of items 
-- <amountShouldBe> - whether the amount of items should be: "equal", "less" or "more" than <amount>
function Finder.checks.nbt.byAmount(item --[[Item]], args --[[table]] )
    if not item.Count then
        return false
    end
    local amount = args.amount
    local itemAmount = item.Count
    local amountShouldBe = args.amountShouldBe

    local amountIs = utils.compare(itemAmount, amount) -- checks whether the amount of items is more/less/equal as amount

    return amountIs == amountShouldBe
end




--[[
    int <minimalShulkerMatches> = [...] -- specifies amount of matches inside the shulkerbox required for it to pass
    string <minimalShulkerMatchesShouldBe> = [...] -- check utils.compare, accepts: "equal", "more", "less"
]]
function Finder.checks.byContainer(item --[[Item]], args --[[table]])
    if not item.nbt or not item.nbt.tag or not item.nbt.tag.BlockEntityTag or not item.nbt.tag.BlockEntityTag.Items then return false end -- if the item is not a shulkerbox, return
    local containerChecks = args.checks
    local containerArgs = args.args
    containerArgs.item = item

    local matchingItems = Finder.advancedShulkerSearch(containerChecks,containerArgs)

    if not matchingItems then return false end

    local minimalShulkerMatches = args.minimalShulkerMatches
    local minimalShulkerMatchesShouldBe = args.minimalShulkerMatchesShouldBe
    if minimalShulkerMatches then
        return utils.compare(#matchingItems,minimalShulkerMatches) == minimalShulkerMatchesShouldBe
    else
        return true
    end
end

-- simple 
function Finder.find(itemName,slots)
    slots = Finder.mappings.getMappings(slots)
    local item
    for _,slot in ipairs(slots) do
        item = inv.getSlot(slot)
        if item and item.name == itemName then
            return slot
        end
    end
    return false
end


--[[
< checks > expected structure:
array <checks> = {
    table {
        function <checkFunction> = [...] -- function that tests the item
        table <functionArgs> = {
            int <passValue> = [...] -- defaults to 1, defines amount of passes incremented if the check suceeeds
            -- arguments expected by chosen function <check>
        }
    }
}

< args > expected structure: 
table <args> = {
    string <slots> = [...] -- defaults to "all", defines slots thru which we search
    int <minimalPasses> = [...] -- defaults to false, defines minimal amount of passes required to accept the slot
    bool <findMultiple> = [...] -- defaults to false, specifies the return type of the function, if enabled it returns a table of ints, otherwise int
}

]]
function Finder.advancedSearch( checks --[[table]], args --[[table]])
    assert(type(checks) == "table", ("checks should be <table> not: %s"):format(type(checks)))
    assert(type(args) == "table", ("args should be <table> not: %s"):format(type(args)))

    assert(#checks ~= 0, (( "%s no checking functions specified!" ):format(tostring(#checks))))

    local findMultiple = args.findMultiple or false
    local minimalPasses = args.minimalPasses or #checks

    local slots = args.slots or "all"
    slots = Finder.mappings.getMappings(slots)

    local item
    local found
    local foundItems = {}

    for _,slot in ipairs(slots) do
        found = false
        item = inv.getSlot(slot)
        if item then
            local passes = 0

            for _, check in pairs(checks) do
                local functionArgs = check.functionArgs
                local passValue = functionArgs.passValue or 1
                local checkFunction = check.checkFunction
                if checkFunction(item, functionArgs) == true then passes = passes + passValue end
            end

            if passes >= minimalPasses then found = true end

            if found then
                if findMultiple then
                    foundItems[#foundItems+1] = slot
                else
                    return slot
                end
            end
        end
    end
    if #foundItems > 0 then return foundItems else return false end
end






--[[

< checks > expected structure:
array <checks> = {
    table {
        function <checkFunction> = [...] -- function that tests the item NOTE: in advancedShulkerSearch you should use the NBT checks, as the items in shulkerboxes dont have values used by normal checks
        table <functionArgs> = {
            int <passValue> = [...] -- defaults to 1, defines amount of passes incremented if the check suceeeds
            -- arguments expected by chosen function <check>
        }
    }
}

< args > expected structure: 
table <args> = {
    int/table <item> = {...} -- the item can be either an int (slot in the inventory) or Item instance.
    int <minimalPasses> = [...] -- defaults to false, defines minimal amount of passes required to accept the slot
    bool <findMultiple> = [...] -- defaults to false, specifies the return type of the function, if enabled it returns a table of ints, otherwise int
}
]]
function Finder.advancedShulkerSearch( checks, args )
    assert(type(checks) == "table", ("checks should be <table> not: %s"):format(type(checks)))
    assert(type(args) == "table", ("args should be <table> not: %s"):format(type(args)))

    assert(type(args.item) == "table" or type(args.item) == "number", ("item should be <table> or <number> not %s"):format(type(args.item)))

    local shulker

    if type(args.item) == "number" then
        shulker = inv.getSlot(args.item)
    elseif type(args.item) == "table" then
        shulker = args.item
    end

    assert( shulker.nbt and shulker.nbt.tag and shulker.nbt.tag.BlockEntityTag and shulker.nbt.tag.BlockEntityTag.Items, ( "&4 %s does not have items! &f" ):format(shulker.id))

    local findMultiple = args.findMultiple or false
    local minimalPasses = args.minimalPasses or #checks


    local found
    local foundItems = {}
    local shulkerBoxContents = shulker.nbt.tag.BlockEntityTag.Items

    for _,item in ipairs(shulkerBoxContents) do
        found = false
        if item then
            local passes = 0

            for _, check in pairs(checks) do
                local functionArgs = check.functionArgs
                local passValue = functionArgs.passValue or 1
                local checkFunction = check.checkFunction
                if checkFunction(item, functionArgs) == true then passes = passes + passValue end
            end

            if passes >= minimalPasses then found = true end

            if found then
                if findMultiple then
                    foundItems[#foundItems+1] = item.Slot + 1 -- java mappings start at 0, we add 1 to adjust this for lua mappings
                else
                    return item.Slot + 1 -- java mappings start at 0, we add 1 to adjust this for lua mappings
                end
            end
        end
    end
    if #foundItems > 0 then return foundItems else return false end
end

return Finder
