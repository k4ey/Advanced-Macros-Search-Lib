local Finder = run('finder.lua')


log(Finder.advancedSearch(
{
    {
        checkFunction = Finder.checks.byAmount,
        functionArgs = {
            passValue = 2,
            amount = 10,
            amountShouldBe = "equal"
        }
    },
    {
        checkFunction = Finder.checks.byName,
        functionArgs = {
            passValue = 4,
            name = "podzo",
            ignoreCase = true,
            exact = true
        }
    },
    {
        checkFunction = Finder.checks.byId,
        functionArgs = {
            passValue = 1,
            id = "dirt",
            insertSuffix = true,
            exact = true
        }
    }
},
{
    minimalPasses = 7,
    slots = "all",
    findMultiple = true,
}
))

local shulkerSearchChecks = {
    {
        checkFunction = Finder.checks.nbt.byAmount,
        functionArgs = {
            amount = 10,
            amountShouldBe = "equal"
        }
    },
    {
        checkFunction = Finder.checks.nbt.byId,
        functionArgs = {
            id = "stone",
            insertSuffix = true,
            exact = false
        }
    },
}
local shulkerSearchArgs = {
    findMultiple = true,
}

log(Finder.advancedSearch(
{
    {
        checkFunction = Finder.checks.byContainer,
        functionArgs = {
            checks = shulkerSearchChecks,
            args = shulkerSearchArgs,
            minimalShulkerMatches = 6,
            minimalShulkerMatchesShouldBe= "more",
        }
    },
    {
        checkFunction = Finder.checks.byContainer,
        functionArgs = {
            checks = shulkerSearchChecks,
            args = shulkerSearchArgs,
            minimalShulkerMatches = 6,
            minimalShulkerMatchesShouldBe= "equal",
        }
    },
    {
        checkFunction = Finder.checks.byName,
        functionArgs = {
            name = "shalker",
            ignoreCase = true,
            exact = true
        }
    },
},
{
    slots = "all",
    findMultiple = true,
    minimalPasses = 2
}
))

local shulkerSearchChecks = {
    {
        checkFunction = Finder.checks.nbt.byAmount,
        functionArgs = {
            amount = 64,
            amountShouldBe = "equal"
        }
    },
    {
        checkFunction = Finder.checks.nbt.byId,
        functionArgs = {
            id = "end_crystal",
            insertSuffix = true,
            exact = true
        }
    },
}
local shulkerSearchArgs = {
    findMultiple = true,
}

Finder.advancedSearch(
{
    {
        checkFunction = Finder.checks.byContainer,
        functionArgs = {
            checks = shulkerSearchChecks,
            args = shulkerSearchArgs,
            minimalShulkerMatches = 2,
            minimalShulkerMatchesShouldBe= "equal",
        }
    },
    {
        checkFunction = Finder.checks.byName,
        functionArgs = {
            name = "pvp",
            ignoreCase = true,
            exact = false
        }
    },
},
{
    slots = "all",
    findMultiple = true
}
)
local shulkerSearchChecks = {
    {
        checkFunction = Finder.checks.nbt.byAmount,
        functionArgs = {
            amount = 64,
            amountShouldBe = "equal"
        }
    },
    {
        checkFunction = Finder.checks.nbt.byId,
        functionArgs = {
            id = "end_crystal",
            insertSuffix = true,
            exact = true
        }
    },
}
local shulkerSearchArgs = {
    findMultiple = true,
}

log(Finder.advancedSearch(
{
    {
        checkFunction = Finder.checks.byContainer,
        functionArgs = {
            checks = shulkerSearchChecks,
            args = shulkerSearchArgs,
            minimalShulkerMatches = 5,
            minimalShulkerMatchesShouldBe= "equal",
        }
    },
    {
        checkFunction = Finder.checks.byName,
        functionArgs = {
            name = "cristal",
            ignoreCase = true,
            exact = false
        }
    },
},
{
    slots = "all",
    findMultiple = true
}
))
