local inv = openInventory()
local Finder = {}
Finder.mappings = {}
Finder.mappings.inventory = {
    [63]={ starts=28,ends=63 }, -- single chest
    [90]={ starts=57,ends=90 }, -- double chest
    [46]={ starts=10,ends=45 }, -- nothing opened
    [53]={ starts=18,ends=53 } -- donkey
}
Finder.mappings.container = {
    [63]={ starts=1,ends=27 }, -- single chest
    [90]={ starts=1,ends=56 }, -- double chest
    [46]={ starts=10,ends=45 }, -- nothing opened
    [53]={ starts=3,ends=17 } -- donkey
}

--translates mappings "inventory","container","all",{start,end},{slot1,slot2,slot3...}
function Finder.mappings.getMappings(slots)
    local totalSlots = inv.getTotalSlots()
    -- inventory         - from the end of the chest to the last slot of the inventory
    -- container         - from the first slot of a container to the last slot of the container
    -- all               - from the first slot of a container to the last slot of the inventory
    -- <table>#2         - range from first to the second 
    -- <table>#1 or more - every given slot

    if slots == "inventory" then
        slots = {
            starts=Finder.mappings.inventory[totalSlots].starts,
            ends=Finder.mappings.inventory[totalSlots].ends}

    elseif slots == "container" then
        assert(totalSlots ~= 46, "no containers are open!")
        slots = {
            starts=Finder.mappings.container[totalSlots].starts,
            ends=Finder.mappings.container[totalSlots].ends}

    elseif slots == "all" then
        slots = {
            starts=Finder.mappings.container[totalSlots].starts,
            ends=Finder.mappings.inventory[totalSlots].ends}

    elseif type(slots) == "table" and #slots == 2 then
        slots = {
            starts=slots[1],
            ends=slots[2]}
    elseif type(slots) == "table" and ( #slots > 2 or #slots == 1 ) then
        return slots
    end
    local iterSlots = {}
    for i=slots.starts,slots.ends do
        iterSlots[#iterSlots+1] = i
    end
    return iterSlots
end

-- compares a and b
-- returns: equal/more/less
local function compare(a,b)
    assert(type(a) == "number" and type(b) == "number", ( "cannot compare: %s and %s" ):format(type(a),type(b)))
    if a == b then return "equal"
    elseif a < b then return "less"
    elseif a > b then return "more"
    end
end

-- <s1> - string 1 
-- <s2> - string 2 
-- <exact = true> - whether the string should be exactly matched (DEFAULTS TO TRUE)
local function find(s1,s2,exact)
    if exact == nil then exact = true end
    if exact then
        return s1 == s2
    else
        return s1:find(s2) ~= nil
    end
end

Finder.checks = {}
Finder.checks.nbt = {}



-- <item> - item to check
-- <amount> - amount of items 
-- <amountShouldBe> - whether the amount of items should be: "equal", "less" or "more" than <amount>
function Finder.checks.byAmount(item --[[Item]], args --[[table]] )
    local amount = args.amount
    local amountShouldBe = args.amountShouldBe
    local amountIs = compare(item.amount, amount) -- checks whether the amount of items is more/less/equal as amount

    return amountIs == amountShouldBe
end

-- <item> - item to check
-- <id> - id of the item
-- <insertSuffix> - every id has "minecraft:" suffix - should it be inserted?
function Finder.checks.byId(item --[[Item]], args --[[table]])
    local insertSuffix = args.insertSuffix
    local id = args.id
    if insertSuffix then id = "minecraft:" .. id end
    return find( item.id, id , args.exact.byId)
end

-- <item> - item to check
-- <ignoreCase> - whether the check should be CaSe SenSitiVe
function Finder.checks.byName(item --[[Item]], args --[[table]])
    local ignoreCase = args.ignoreCase
    if ignoreCase then args.name = string.lower(args.name); item.name = string.lower(item.name)  end
    return find( item.name, args.name, args.exact.byName)
end

-- <item> - item to check
-- <ignoreCase> - whether the check should be CaSe SenSitiVe
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

    if ignoreCase then args.name = string.lower(args.name); itemName = string.lower(itemName)  end
    return find( itemName, args.name, args.exact.byName)
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

    local amountIs = compare(itemAmount, amount) -- checks whether the amount of items is more/less/equal as amount

    return amountIs == amountShouldBe
end

-- this function allows you to find a shulkerbox that contains specific item with specific properties. It scans thru every slot inside and applies checkFunctions to each item inside, just like advancedSearch.
-- <item> - item to check
-- <container> -- arguments for items inside the shulkerbox
-- <containerArgs.checkFunctions> -- checks applied to every item inside the shulker box, if every check passes, then this function returns true
-- <amountOfMatches> - same as <amount> in <Finder.checks.byAmount> - but for amount of slots matching <containerArgs>
-- <amountOfMatchesShouldBe> - same as <amountShouldBe> in <Finder.checks.byAmount> - but for matching <amount> (accepts: "equal", "less", "more")
-- every arg that works on advancedSearch should work on them too
function Finder.checks.byContainer(item --[[Item]], args --[[table]])
    if not item.nbt or not item.nbt.tag or not item.nbt.tag.BlockEntityTag or not item.nbt.tag.BlockEntityTag.Items then return false end -- if the item is not a shulkerbox, return
    local containerArgs = args.containerArgs
    --[[ log(item)
    log(containerArgs.checkFunctions)
    log(containerArgs) ]]
    local matchingItems = Finder.advancedShulkerSearch(item, containerArgs.checkFunctions, containerArgs, true)

    if not matchingItems then return false end

    local amountOfMatches = containerArgs.amountOfMatches
    local amountOfMatchesShouldBe = containerArgs.amountOfMatchesShouldBe
    if amountOfMatches then
        return compare(#matchingItems, amountOfMatches) == amountOfMatchesShouldBe
    end
    return true
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



-- <itemName> - name of the item
-- <slots>    - range of search, see <getMappings> for more info
-- <checkFunctions> - function that checks whether the item is wanted. (or an array of functions)
-- <findMultiple> - true/false, returns a table of items, or just one
-- <tolerance> - amount of tests that can fail until the item is discarded.
function Finder.advancedSearch( slots --[[int]], checkFunctions --[[table/function]], args --[[table]], findMultiple --[[boolean]], tolerance --[[int]])
    assert(type(checkFunctions) == "function" or type(checkFunctions) == "table", ("checkFunctions cannot be: %s"):format(type(checkFunctions)))
    assert(type(args) == "table", ("args should be <table> not: %s"):format(type(args)))
    -- assert(type(findMultiple) == "boolean", ("findMultiple should be <boolean> not: %s"):format(type(findMultiple)))

    findMultiple = findMultiple or false
    tolerance = tolerance or 0
    args.exact = args.exact or {}

    slots = Finder.mappings.getMappings(slots)
    local item
    local found
    local foundItems = {}

    if type(checkFunctions) == "function" then checkFunctions = {checkFunctions} end

    for _,slot in ipairs(slots) do
        found = false
        item = inv.getSlot(slot)
        if item then
            local passed = 0

            for _, checkFunction in pairs(checkFunctions) do -- iterate over given functions
                if checkFunction(item, args) == true then passed = passed + 1 end -- if the check passes, increment passed
            end

            if passed + tolerance >= #checkFunctions then found = true end -- if the amount of passes equals the amount of functions, then the item we are searching for is found.

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

-- <shulker> 
-- <checkFunctions> - function that checks whether the item is wanted. (or an array of functions)
-- <findMultiple> - true/false, returns a table of items, or just one
-- <tolerance> - amount of tests that can fail until the item is discarded.
function Finder.advancedShulkerSearch( shulker --[[int]], checkFunctions --[[table/function]], args --[[table]], findMultiple --[[boolean]])
    assert(type(checkFunctions) == "function" or type(checkFunctions) == "table", ("checkFunctions cannot be: %s"):format(type(checkFunctions)))
    assert(type(args) == "table", ("args should be <table> not: %s"):format(type(args)))
    assert( shulker.nbt and shulker.nbt.tag and shulker.nbt.tag.BlockEntityTag and shulker.nbt.tag.BlockEntityTag.Items, ( "&4 %s does not have items! &f" ):format(shulker.id))
    for i=1, #checkFunctions do
        assert(type(checkFunctions[i]) == "function", ("%s is not a function"):format(type(checkFunctions[i])))
    end
    findMultiple = findMultiple or false
    tolerance = tolerance or 0
    args.exact = args.exact or {}
    local found
    local passed
    local foundItems = {}

    local shulkerBoxContents = shulker.nbt.tag.BlockEntityTag.Items

    if type(checkFunctions) == "function" then checkFunctions = {checkFunctions} end
    for _, item in ipairs(shulkerBoxContents) do
        found = false
        if item then
            passed = 0

            for _, checkFunction in pairs(checkFunctions) do -- iterate over given functions
                if checkFunction(item, args) == true then passed = passed + 1 end -- if the check passes, increment passed
            end

            if passed+tolerance >= #checkFunctions then found = true end -- if the amount of passes equals the amount of functions, then the item we are searching for is found.

            if found then
                if findMultiple then
                    foundItems[#foundItems+1] = item.Slot + 1 -- +1 because the JAVA mappings start at 0 
                else
                    return item.Slot + 1 -- ^
                end
            end
        end
    end
    if #foundItems > 0 then return foundItems else return false end
end

return Finder
