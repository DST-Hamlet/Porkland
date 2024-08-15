local RemoveDefaultCharacter = RemoveDefaultCharacter
GLOBAL.setfenv(1, GLOBAL)

local dst_characters = {
    -- "winona",
    -- "warly",
    "wortox",
    -- "wormwood",
    "wurt",
    "walter",
    "wanda",
    "wonkey", --hidden internal char
}

for _, character in pairs(dst_characters) do
    RemoveDefaultCharacter(character)
end
