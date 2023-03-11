local mappings = {}
mappings.inventory = {
    [63]={ starts=28,ends=63 }, -- single chest
    [90]={ starts=57,ends=90 }, -- double chest
    [46]={ starts=10,ends=45 }, -- nothing opened
    [53]={ starts=18,ends=53 } -- donkey
}
mappings.container = {
    [63]={ starts=1,ends=27 }, -- single chest
    [90]={ starts=1,ends=56 }, -- double chest
    [46]={ starts=10,ends=45 }, -- nothing opened
    [53]={ starts=3,ends=17 } -- donkey
}

--translates mappings "inventory","container","all",{start,end},{slot1,slot2,slot3...}
function mappings.getMappings(slots)
    local inv = openInventory()
    local totalSlots = inv.getTotalSlots()
    -- inventory         - from the end of the chest to the last slot of the inventory
    -- container         - from the first slot of a container to the last slot of the container
    -- all               - from the first slot of a container to the last slot of the inventory
    -- <table>#2         - range from first to the second 
    -- <table>#1 or more - every given slot

    if slots == "inventory" then
        slots = {
            starts=mappings.inventory[totalSlots].starts,
            ends=mappings.inventory[totalSlots].ends}

    elseif slots == "container" then
        assert(totalSlots ~= 46, "no containers are open!")
        slots = {
            starts=mappings.container[totalSlots].starts,
            ends=mappings.container[totalSlots].ends}

    elseif slots == "all" then
        slots = {
            starts=mappings.container[totalSlots].starts,
            ends=mappings.inventory[totalSlots].ends}

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

return mappings
