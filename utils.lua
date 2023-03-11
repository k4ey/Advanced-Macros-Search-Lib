local utils = {}

-- compares a and b
-- returns: equal/more/less
function utils.compare(a,b)
    assert(type(a) == "number" and type(b) == "number", ( "cannot compare: %s and %s" ):format(type(a),type(b)))
    if a == b then return "equal"
    elseif a < b then return "less"
    elseif a > b then return "more"
    end
end

-- <s1> - string 1 
-- <s2> - string 2 
-- <exact = true> - whether the string should be exactly matched (DEFAULTS TO TRUE)
function utils.find(s1,s2,exact)
    if exact == nil then exact = true end
    if exact then
        return s1 == s2
    else
        return s1:find(s2) ~= nil
    end
end

-- table <t>
function utils.countEntries(t)
    local count = 0
    for _, _ in pairs(t) do
        count = count + 1
    end
    return count
end

return utils
