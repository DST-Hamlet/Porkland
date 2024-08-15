GLOBAL.setfenv(1, GLOBAL)

local skilltreedefs = require("prefabs/skilltree_defs")

for _, characterprefab in pairs(DST_CHARACTERLIST) do -- use this so we don't mess with other mods
    if skilltreedefs.SKILLTREE_DEFS[characterprefab] then
        skilltreedefs.SKILLTREE_DEFS[characterprefab] = nil
    end
end
