RTV = RTV or {} -- Ignore

RTV.Prefixes = { -- Prefixes, the text at the start of your map files. Leave empty to use all maps.
	"psw_",
}

-- If you want a specific map added, but not all with that prefix, just add the map name.
-- For example, say I want gm_construct but not gm_flatgrass. Instead of adding "gm_" to the prefixes,
-- I would just add "gm_construct"

RTV.Limit = 5 -- The amount of maps added to the vote (if available). Can only be 2-8. There is always one additional option added to extend the map.

RTV.Wait = 10 -- The wait time in seconds. This is how long a player has to wait before voting when the map changes. If the "extend" option is picked, you have to wait double this before voting again.

RTV.Duration = 30

RTV.ChatCommand = "rtv" -- Automatically works with ! or /

RTV.ExcludedMaps = { -- Format: ["mapname"] = true
	-- ["example"] = true, -- prevent "example" from being in the pool
}
