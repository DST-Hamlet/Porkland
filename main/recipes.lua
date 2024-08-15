local AddDeconstructRecipe = AddDeconstructRecipe
local AddRecipe2 = AddRecipe2
local AddRecipeFilter = AddRecipeFilter
GLOBAL.setfenv(1, GLOBAL)

local function SortRecipe(a, b, filter_name, offset)
    local filter = CRAFTING_FILTERS[filter_name]
    if filter and filter.recipes then
        for sortvalue, product in ipairs(filter.recipes) do
            if product == a then
                table.remove(filter.recipes, sortvalue)
                break
            end
        end

        local target_position = #filter.recipes + 1
        for sortvalue, product in ipairs(filter.recipes) do
            if product == b then
                target_position = sortvalue + offset
                break
            end
        end
        table.insert(filter.recipes, target_position, a)
    end
end

local function SortBefore(a, b, filter_name)  -- a before b
    SortRecipe(a, b, filter_name, 0)
end

local function SortAfter(a, b, filter_name)  -- a after b
    SortRecipe(a, b, filter_name, 1)
end

local function AquaticRecipe(name, data)
    if AllRecipes[name] then
        -- data = {distance=, shore_distance=, platform_distance=, shore_buffer_max=, shore_buffer_min=, platform_buffer_max=, platform_buffer_min=, aquatic_buffer_min=, noshore=}
        data = data or {}
        data.platform_buffer_max = data.platform_buffer_max or
                                       (data.platform_distance and math.sqrt(data.platform_distance)) or
                                       (data.distance and math.sqrt(data.distance)) or nil
        data.shore_buffer_max = data.shore_buffer_max or (data.shore_distance and ((data.shore_distance + 1) / 2)) or
                                    nil
        AllRecipes[name].aquatic = data
        AllRecipes[name].build_mode = BUILDMODE.WATER
    end
end



-- Clear ALL of the DST recipes
RemoveAllRecipes()

local tabs_to_delete = {"SEAFARING", "RIDING", "WINTER", "SUMMER", "FISHING"}
for _, tab in pairs(tabs_to_delete) do
    RemoveByValue(CRAFTING_FILTER_DEFS, CRAFTING_FILTERS[tab])
    CRAFTING_FILTERS[tab] = nil
end


local function IsMarshLand(pt, rot)
    local ground_tile = TheWorld.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
    return ground_tile and ground_tile == WORLD_TILES.MARSH
end


local function telebase_testfn(pt, rot)
    --See telebase.lua
    local telebase_parts =
    {
        { x = -1.6, z = -1.6 },
        { x =  2.7, z = -0.8 },
        { x = -0.8, z =  2.7 },
    }
    rot = (45 - rot) * DEGREES
    local sin_rot = math.sin(rot)
    local cos_rot = math.cos(rot)
    for i, v in ipairs(telebase_parts) do
        if not TheWorld.Map:IsVisualGroundAtPoint(pt.x + v.x * cos_rot - v.z * sin_rot, pt.y, pt.z + v.z * cos_rot + v.x * sin_rot) then
            return false
        end
    end
    return true
end

--[[ DST&Porkland Recipes ]]

Recipe2("amulet",                       {Ingredient("goldnugget", 3), Ingredient("nightmarefuel", 2),Ingredient("redgem", 1)},            TECH.MAGIC_TWO)
Recipe2("armor_sanity",                 {Ingredient("nightmarefuel", 5),Ingredient("papyrus", 3)},                                        TECH.MAGIC_THREE)
Recipe2("armordragonfly",               {Ingredient("dragon_scales", 1), Ingredient("armorwood", 1), Ingredient("pigskin", 3)},            TECH.LOST)
Recipe2("armorgrass",                    {Ingredient("cutgrass", 10), Ingredient("twigs", 2)},                                            TECH.NONE)
Recipe2("armorwood",                    {Ingredient("log", 8), Ingredient("rope", 2)},                                                    TECH.SCIENCE_ONE)
Recipe2("axe",                          {Ingredient("twigs", 1), Ingredient("flint", 1)},                                                TECH.NONE)
Recipe2("backpack",                        {Ingredient("cutgrass", 4), Ingredient("twigs", 4)},                                            TECH.SCIENCE_ONE)
Recipe2("bandage",                        {Ingredient("papyrus", 1), Ingredient("honey", 2)},                                                TECH.SCIENCE_TWO)
Recipe2("batbat",                        {Ingredient("batwing", 3), Ingredient("livinglog", 2), Ingredient("purplegem", 1)},                TECH.MAGIC_THREE)
Recipe2("beargervest",                     {Ingredient("bearger_fur", 1), Ingredient("sweatervest", 1), Ingredient("rope", 2)},            TECH.LOST)
Recipe2("bedroll_straw",                {Ingredient("cutgrass", 6), Ingredient("rope", 1)},                                                TECH.SCIENCE_ONE)
Recipe2("beeswax",                        {Ingredient("honeycomb", 1)},                                                                     TECH.SCIENCE_TWO)
Recipe2("birdcage",                        {Ingredient("papyrus", 2), Ingredient("goldnugget", 6), Ingredient("seeds", 2)},                TECH.SCIENCE_TWO,            {placer="birdcage_placer"})
Recipe2("birdtrap",                        {Ingredient("twigs", 3), Ingredient("silk", 4)},                                                TECH.SCIENCE_ONE)
Recipe2("blowdart_fire",                {Ingredient("cutreeds", 2), Ingredient("charcoal", 1), Ingredient("feather_robin", 1)},            TECH.SCIENCE_TWO)
Recipe2("blowdart_pipe",                {Ingredient("cutreeds", 2), Ingredient("houndstooth", 1),Ingredient("feather_robin_winter", 1)},TECH.SCIENCE_TWO)
Recipe2("blowdart_sleep",                {Ingredient("cutreeds", 2), Ingredient("stinger", 1), Ingredient("feather_crow", 1)},            TECH.SCIENCE_TWO)
Recipe2("blueamulet",                    {Ingredient("goldnugget", 3), Ingredient("bluegem", 1)},                                        TECH.MAGIC_TWO)
Recipe2("boards",                        {Ingredient("log", 4)},                                                                         TECH.SCIENCE_ONE)
Recipe2("boomerang",                    {Ingredient("boards", 1),Ingredient("silk", 1),Ingredient("charcoal", 1)},                        TECH.SCIENCE_TWO)
Recipe2("bugnet",                        {Ingredient("twigs", 4), Ingredient("silk", 2), Ingredient("rope", 1)},                            TECH.SCIENCE_ONE)
Recipe2("bundlewrap",                    {Ingredient("waxpaper", 1), Ingredient("rope", 1)},                                                TECH.LOST)
Recipe2("bushhat",                        {Ingredient("strawhat", 1),Ingredient("rope", 1),Ingredient("dug_berrybush", 1)},                TECH.SCIENCE_TWO)
Recipe2("campfire",                        {Ingredient("cutgrass", 3),Ingredient("log", 2)},                                                TECH.NONE,                    {placer="campfire_placer",            min_spacing=2})
Recipe2("cane",                         {Ingredient("goldnugget", 2), Ingredient("walrus_tusk", 1), Ingredient("twigs", 4)},            TECH.LOST)
Recipe2("compass",                        {Ingredient("goldnugget", 1), Ingredient("flint", 1)},                                            TECH.NONE)
Recipe2("cookpot",                        {Ingredient("cutstone", 3), Ingredient("charcoal", 6), Ingredient("twigs", 6)},                    TECH.SCIENCE_ONE,            {placer="cookpot_placer", min_spacing=2})
Recipe2("cutstone",                     {Ingredient("rocks", 3)},                                                                         TECH.SCIENCE_ONE)
Recipe2("eyebrellahat",                 {Ingredient("deerclops_eyeball", 1), Ingredient("twigs", 15), Ingredient("boneshard", 4)},         TECH.LOST)
Recipe2("featherfan",                   {Ingredient("goose_feather", 5), Ingredient("cutreeds", 2), Ingredient("rope", 2)},                TECH.LOST)
Recipe2("featherpencil",                {Ingredient("twigs", 1), Ingredient("charcoal", 1), Ingredient("feather_crow", 1)},             TECH.SCIENCE_ONE)
Recipe2("fence_gate_item",                {Ingredient("boards", 2), Ingredient("rope", 1)},                                                TECH.SCIENCE_TWO)
Recipe2("fence_item",                    {Ingredient("twigs", 3), Ingredient("rope", 1)},                                                TECH.SCIENCE_ONE,            {numtogive=6})
Recipe2("fertilizer",                    {Ingredient("poop", 3), Ingredient("boneshard", 2), Ingredient("log", 4)},                        TECH.SCIENCE_TWO)
Recipe2("firepit",                        {Ingredient("log", 2),Ingredient("rocks", 12)},                                                    TECH.NONE,                    {placer="firepit_placer",            min_spacing=2.5})
Recipe2("firestaff",                    {Ingredient("nightmarefuel", 2), Ingredient("spear", 1), Ingredient("redgem", 1)},                TECH.MAGIC_THREE)
Recipe2("firesuppressor",                {Ingredient("gears", 2),Ingredient("ice", 15),Ingredient("transistor", 2)},                        TECH.SCIENCE_TWO,            {placer="firesuppressor_placer",    min_spacing=2.5})
Recipe2("fishingrod",                    {Ingredient("twigs", 2), Ingredient("silk", 2)},                                                TECH.SCIENCE_ONE)
Recipe2("flowerhat",                     {Ingredient("petals", 12)},                                                                     TECH.NONE)
Recipe2("footballhat",                    {Ingredient("pigskin", 1), Ingredient("rope", 1)},                                                TECH.SCIENCE_TWO)
Recipe2("goldenaxe",                    {Ingredient("twigs", 4),Ingredient("goldnugget", 2)},                                            TECH.SCIENCE_TWO)
Recipe2("goldenpickaxe",                {Ingredient("twigs", 4),Ingredient("goldnugget", 2)},                                            TECH.SCIENCE_TWO)
Recipe2("goldenshovel",                    {Ingredient("twigs", 4),Ingredient("goldnugget", 2)},                                            TECH.SCIENCE_TWO)
Recipe2("gunpowder",                    {Ingredient("rottenegg", 1), Ingredient("charcoal", 1), Ingredient("nitre", 1)},                TECH.SCIENCE_TWO)
Recipe2("hambat",                        {Ingredient("pigskin", 1), Ingredient("twigs", 2), Ingredient("meat", 2)},                        TECH.SCIENCE_TWO)
Recipe2("hammer",                        {Ingredient("twigs", 3),Ingredient("rocks", 3), Ingredient("cutgrass", 6)},                        TECH.NONE)
Recipe2("healingsalve",                    {Ingredient("ash", 2), Ingredient("rocks", 1), Ingredient("spidergland",1)},                    TECH.SCIENCE_ONE)
Recipe2("homesign",                        {Ingredient("boards", 1)},                                                                        TECH.SCIENCE_ONE,            {placer="homesign_placer",            min_spacing=1.5})
Recipe2("arrowsign_post",                {Ingredient("boards", 1)},                                                                        TECH.SCIENCE_ONE,            {placer="arrowsign_post_placer",    min_spacing=1.5})
Recipe2("icebox",                        {Ingredient("goldnugget", 2), Ingredient("gears", 1), Ingredient("cutstone", 1)},                TECH.SCIENCE_TWO,            {placer="icebox_placer",            min_spacing=1.5})
Recipe2("icepack",                        {Ingredient("bearger_fur", 1), Ingredient("gears", 1), Ingredient("transistor", 1)},            TECH.LOST)
Recipe2("icestaff",                        {Ingredient("spear", 1),Ingredient("bluegem", 1)},                                                TECH.MAGIC_TWO)
Recipe2("lantern",                        {Ingredient("twigs", 3), Ingredient("rope", 2), Ingredient("lightbulb", 2)},                    TECH.SCIENCE_TWO)
Recipe2("lightning_rod",                {Ingredient("goldnugget", 4), Ingredient("cutstone", 1)},                                        TECH.SCIENCE_ONE,            {placer="lightning_rod_placer",        min_spacing=1})
Recipe2("meatrack",                        {Ingredient("twigs", 3),Ingredient("charcoal", 2), Ingredient("rope", 3)},                        TECH.SCIENCE_ONE,            {placer="meatrack_placer"})
Recipe2("minerhat",                        {Ingredient("strawhat", 1),Ingredient("goldnugget", 1),Ingredient("fireflies", 1)},                TECH.SCIENCE_TWO)
Recipe2("minisign_item",                {Ingredient("boards", 1)},                                                                        TECH.SCIENCE_ONE,            {numtogive = 4})
Recipe2("molehat",                        {Ingredient("mole", 2), Ingredient("transistor", 2), Ingredient("wormlight", 1)},                TECH.LOST) -- requries blueprint
Recipe2("nightlight",                    {Ingredient("goldnugget", 8), Ingredient("nightmarefuel", 2), Ingredient("redgem", 1)},            TECH.MAGIC_TWO,                {placer="nightlight_placer",        min_spacing=1.5})
Recipe2("nightmarefuel",                {Ingredient("petals_evil", 4)},                                                                 TECH.MAGIC_TWO)
Recipe2("nightsword",                    {Ingredient("nightmarefuel", 5), Ingredient("livinglog", 1)},                                    TECH.MAGIC_THREE)
Recipe2("onemanband",                    {Ingredient("goldnugget", 2), Ingredient("nightmarefuel", 4), Ingredient("pigskin", 2)},        TECH.MAGIC_TWO)
Recipe2("panflute",                        {Ingredient("cutreeds", 5), Ingredient("mandrake", 1), Ingredient("rope", 1)},                    TECH.MAGIC_TWO)
Recipe2("papyrus",                        {Ingredient("cutreeds", 4)},                                                                     TECH.SCIENCE_ONE)
Recipe2("pickaxe",                        {Ingredient("twigs", 2), Ingredient("flint", 2)},                                                TECH.NONE)
Recipe2("piggyback",                    {Ingredient("pigskin", 4), Ingredient("silk", 6), Ingredient("rope", 2)},                        TECH.SCIENCE_TWO)
Recipe2("pitchfork",                    {Ingredient("twigs", 2), Ingredient("flint", 2)},                                                TECH.SCIENCE_ONE)
Recipe2("purpleamulet",                    {Ingredient("goldnugget", 6), Ingredient("nightmarefuel", 4),Ingredient("purplegem", 2)},        TECH.MAGIC_THREE)
Recipe2("purplegem",                    {Ingredient("redgem",1), Ingredient("bluegem", 1)},                                             TECH.MAGIC_TWO,             {no_deconstruction=true})
Recipe2("rainometer",                    {Ingredient("boards", 2), Ingredient("goldnugget", 2), Ingredient("rope",2)},                    TECH.SCIENCE_ONE,            {placer="rainometer_placer",        min_spacing=2.5})
Recipe2("razor",                        {Ingredient("twigs", 2), Ingredient("flint", 2)},                                                TECH.SCIENCE_ONE)
Recipe2("researchlab",                    {Ingredient("goldnugget", 1),Ingredient("log", 4), Ingredient("rocks", 4)},                        TECH.NONE,                    {placer="researchlab_placer",            min_spacing=2})
Recipe2("researchlab2",                    {Ingredient("boards", 4), Ingredient("cutstone", 2), Ingredient("transistor", 2)},                TECH.SCIENCE_ONE,            {placer="researchlab2_placer",            min_spacing=2})
Recipe2("researchlab3",                    {Ingredient("livinglog", 3), Ingredient("purplegem", 1), Ingredient("nightmarefuel", 7)},        TECH.MAGIC_TWO,                {placer="researchlab3_placer",            min_spacing=2})
Recipe2("resurrectionstatue",            {Ingredient("boards", 4), Ingredient("beardhair", 4), Ingredient(CHARACTER_INGREDIENT.HEALTH, TUNING.EFFIGY_HEALTH_PENALTY)}, TECH.MAGIC_TWO,    {placer="resurrectionstatue_placer", min_spacing=2})
Recipe2("rope",                            {Ingredient("cutgrass", 3)},                                                                    TECH.SCIENCE_ONE)
Recipe2("sewing_kit",                    {Ingredient("log", 1), Ingredient("silk", 8), Ingredient("houndstooth", 2)},                     TECH.SCIENCE_TWO)
Recipe2("shovel",                        {Ingredient("twigs", 2), Ingredient("flint", 2)},                                                TECH.SCIENCE_ONE)
Recipe2("siestahut",                    {Ingredient("silk", 2), Ingredient("boards", 4),Ingredient("rope", 3)},                            TECH.SCIENCE_TWO,            {placer="siestahut_placer"})
Recipe2("spear",                        {Ingredient("twigs", 2), Ingredient("rope", 1), Ingredient("flint", 1) },                        TECH.SCIENCE_ONE)
Recipe2("staff_tornado",                {Ingredient("goose_feather", 10), Ingredient("lightninggoathorn", 1), Ingredient("gears", 1)},    TECH.SCIENCE_TWO)
Recipe2("strawhat",                     {Ingredient("cutgrass", 12)},                                                                     TECH.NONE)
Recipe2("telebase",                        {Ingredient("nightmarefuel", 4), Ingredient("livinglog", 4), Ingredient("goldnugget", 8)},        TECH.MAGIC_THREE,            {placer="telebase_placer", testfn=telebase_testfn})
Recipe2("telestaff",                    {Ingredient("nightmarefuel", 4), Ingredient("livinglog", 2), Ingredient("purplegem", 2)},        TECH.MAGIC_THREE)
Recipe2("tent",                         {Ingredient("silk", 6), Ingredient("twigs", 4), Ingredient("rope", 3)},                            TECH.SCIENCE_TWO,            {placer="tent_placer"})
Recipe2("tophat",                         {Ingredient("silk", 6)},                                                                         TECH.SCIENCE_ONE)
Recipe2("torch",                        {Ingredient("cutgrass", 2), Ingredient("twigs", 2)},                                            TECH.NONE)
Recipe2("transistor",                    {Ingredient("goldnugget", 2), Ingredient("cutstone", 1)},                                        TECH.SCIENCE_ONE)
Recipe2("trap_teeth",                    {Ingredient("log", 1), Ingredient("rope", 1), Ingredient("houndstooth", 1)},                    TECH.SCIENCE_TWO)
Recipe2("trap",                            {Ingredient("twigs", 2), Ingredient("cutgrass", 6)},                                            TECH.NONE)
Recipe2("treasurechest",                {Ingredient("boards", 3)},                                                                        TECH.SCIENCE_ONE,            {placer = "treasurechest_placer",        min_spacing=1})
Recipe2("turf_road",                    {Ingredient("cutstone", 1), Ingredient("flint", 2)},                                            TECH.SCIENCE_TWO,            {numtogive = 4})
Recipe2("turf_woodfloor",                {Ingredient("boards", 1)},                                                                        TECH.SCIENCE_TWO,            {numtogive = 4})
Recipe2("umbrella",                        {Ingredient("twigs", 6), Ingredient("pigskin", 1), Ingredient("silk",2 )},                        TECH.SCIENCE_ONE)
Recipe2("wall_hay_item",                {Ingredient("cutgrass", 4), Ingredient("twigs", 2)},                                            TECH.SCIENCE_ONE,            {numtogive = 4})
Recipe2("wall_stone_item",                {Ingredient("cutstone", 2)},                                                                    TECH.SCIENCE_TWO,            {numtogive = 6})
Recipe2("wall_wood_item",                {Ingredient("boards", 2), Ingredient("rope", 1)},                                                TECH.SCIENCE_ONE,            {numtogive = 8})
Recipe2("waxpaper",                        {Ingredient("papyrus", 1), Ingredient("beeswax", 1)},                                             TECH.SCIENCE_TWO)

--[[ DST Character Crafts ]]
-- Willow
Recipe2("lighter",                      {Ingredient("rope", 1), Ingredient("goldnugget", 1), Ingredient("petals", 3)},                      TECH.NONE,				{builder_tag="pyromaniac"})
Recipe2("bernie_inactive",              {Ingredient("beardhair", 2), Ingredient("beefalowool", 2), Ingredient("silk", 2)},                  TECH.NONE,				{builder_tag="pyromaniac"})

-- Wendy
Recipe2("abigail_flower",				{Ingredient("petals", 6), Ingredient("nightmarefuel", 1)},									TECH.NONE,				{builder_tag="ghostlyfriend"})

-- Wathgrithr
Recipe2("spear_wathgrithr",             {Ingredient("twigs", 2), Ingredient("flint", 2), Ingredient("goldnugget", 2)},                      TECH.NONE,		{builder_tag="valkyrie"})
Recipe2("wathgrithrhat",                {Ingredient("goldnugget", 2), Ingredient("rocks", 2)},                                              TECH.NONE,		{builder_tag="valkyrie"})

-- Wickerbottom
Recipe2("book_gardening", 	 		    {Ingredient("papyrus", 2), Ingredient("seeds", 1), Ingredient("poop", 1)},							TECH.SCIENCE_ONE,		{builder_tag="bookbuilder"})
Recipe2("book_birds",                   {Ingredient("papyrus", 2), Ingredient("bird_egg", 2)},												TECH.NONE,				{builder_tag="bookbuilder"})
Recipe2("book_sleep",                   {Ingredient("papyrus", 2), Ingredient("nightmarefuel", 2)},                                         TECH.MAGIC_TWO,			{builder_tag="bookbuilder"})
Recipe2("book_brimstone",               {Ingredient("papyrus", 2), Ingredient("redgem", 1)},                                                TECH.MAGIC_THREE,		{builder_tag="bookbuilder"})
Recipe2("book_tentacles",               {Ingredient("papyrus", 2), Ingredient("tentaclespots", 1)},                                         TECH.SCIENCE_THREE,		{builder_tag="bookbuilder"})

-- Maxwell
Recipe2("waxwelljournal",				{Ingredient("papyrus", 2), Ingredient("nightmarefuel", 2), Ingredient(CHARACTER_INGREDIENT.HEALTH, 50)},	TECH.NONE,		{builder_tag="shadowmagic"})
Recipe("shadowlumber_builder",			{Ingredient("nightmarefuel", 2), Ingredient("axe", 1), Ingredient(CHARACTER_INGREDIENT.MAX_SANITY, TUNING.SHADOWWAXWELL_SANITY_PENALTY.SHADOWLUMBER)},		nil, TECH.LOST, nil, nil, true, nil, "shadowmagic")
Recipe("shadowminer_builder",			{Ingredient("nightmarefuel", 2), Ingredient("pickaxe", 1), Ingredient(CHARACTER_INGREDIENT.MAX_SANITY, TUNING.SHADOWWAXWELL_SANITY_PENALTY.SHADOWMINER)},	nil, TECH.LOST, nil, nil, true, nil, "shadowmagic")
Recipe("shadowdigger_builder",			{Ingredient("nightmarefuel", 2), Ingredient("shovel", 1), Ingredient(CHARACTER_INGREDIENT.MAX_SANITY, TUNING.SHADOWWAXWELL_SANITY_PENALTY.SHADOWDIGGER)},	nil, TECH.LOST, nil, nil, true, nil, "shadowmagic")
Recipe("shadowduelist_builder",			{Ingredient("nightmarefuel", 2), Ingredient("spear", 1), Ingredient(CHARACTER_INGREDIENT.MAX_SANITY, TUNING.SHADOWWAXWELL_SANITY_PENALTY.SHADOWDUELIST)},	nil, TECH.LOST, nil, nil, true, nil, "shadowmagic")

-- Wes
Recipe2("balloons_empty",				{Ingredient("waterballoon", 4)},																				TECH.NONE,	{builder_tag="balloonomancer", sg_state="makeballoon"})

-- Webber
Recipe2("spidereggsack", 				{Ingredient("silk", 12),  Ingredient("spidergland", 4), Ingredient("papyrus", 3)},		TECH.NONE,				{builder_tag="spiderwhisperer", allowautopick = true,})

-- Warly
Recipe2("portablecookpot_item",         {Ingredient("goldnugget", 2), Ingredient("charcoal", 6), Ingredient("twigs", 6)},               TECH.NONE,              {builder_tag="masterchef"})
Recipe2("spicepack",                    {Ingredient("cutgrass", 4), Ingredient("twigs", 4), Ingredient("nitre", 2)},                    TECH.NONE,              {builder_tag="masterchef"})

-- Wormwood
Recipe2("livinglog", 					{Ingredient(CHARACTER_INGREDIENT.HEALTH, 20)},																	TECH.NONE,	{builder_tag="plantkin", sg_state="form_log", actionstr="GROW", allowautopick = true, no_deconstruction=true})
Recipe2("armor_bramble",				{Ingredient("livinglog", 2), Ingredient("boneshard", 4)},															TECH.NONE,	{builder_tag="plantkin"})
Recipe2("trap_bramble",					{Ingredient("livinglog", 1), Ingredient("boneshard", 1)},															TECH.NONE,	{builder_tag="plantkin"})
Recipe2("compostwrap",					{Ingredient("poop", 5), Ingredient("spoiled_food", 2), Ingredient("nitre", 1)}, 								TECH.NONE,	{builder_tag="plantkin"})

-- Winona
Recipe2("sewing_tape",                    {Ingredient("silk", 1), Ingredient("cutgrass", 3)},                                                TECH.NONE,                {builder_tag="handyperson"})

--[[ DST Regular Crafts ]]
Recipe2("cartographydesk",                {Ingredient("compass", 1),Ingredient("boards", 4)},                                                TECH.SCIENCE_ONE,            {placer="cartographydesk_placer",        min_spacing=2})
Recipe2("compass",                        {Ingredient("goldnugget", 1), Ingredient("flint", 1)},                                            TECH.NONE)
Recipe2("cookbook",                        {Ingredient("papyrus", 1), Ingredient("carrot", 1)},                                            TECH.SCIENCE_ONE)
Recipe2("featherpencil",                {Ingredient("twigs", 1), Ingredient("charcoal", 1), Ingredient("feather_crow", 1)},             TECH.SCIENCE_ONE)
Recipe2("fence_rotator",                {Ingredient("spear", 1), Ingredient("flint", 2) },                                                TECH.SCIENCE_TWO)
Recipe2("goldenpitchfork",                {Ingredient("twigs", 4),Ingredient("goldnugget", 2)},                                            TECH.SCIENCE_TWO)
Recipe2("grass_umbrella",                {Ingredient("twigs", 4) ,Ingredient("cutgrass", 3), Ingredient("petals", 6)},                    TECH.NONE)
Recipe2("mapscroll",                    {Ingredient("featherpencil", 1), Ingredient("papyrus", 1)},                                     TECH.CARTOGRAPHY_TWO,        {nounlock=true, actionstr="CARTOGRAPHY"})
Recipe2("miniflare",                    {Ingredient("twigs", 1), Ingredient("cutgrass", 1), Ingredient("nitre", 1)},                    TECH.NONE)
Recipe2("mushroom_farm",                {Ingredient("spoiled_food", 8),Ingredient("poop", 5),Ingredient("livinglog", 2)},                TECH.SCIENCE_TWO,            {placer="mushroom_farm_placer",        min_spacing=2})
Recipe2("reskin_tool",                    {Ingredient("twigs", 1), Ingredient("petals", 4)},                                                TECH.SCIENCE_TWO)
Recipe2("wardrobe",                        {Ingredient("boards", 4), Ingredient("cutgrass", 3)},                                            TECH.SCIENCE_TWO,            {placer="wardrobe_placer",                        min_spacing=2.5})
Recipe2("waterballoon",                    {Ingredient("mosquitosack", 2), Ingredient("ice", 1)},                                            TECH.SCIENCE_ONE,            {numtogive = 4})

-- AddRecipeFilter(filter_def, index)
-- index: insertion order
-- filter_def.name: This is the filter's id and will need the string added to STRINGS.UI.CRAFTING_FILTERS[name]
-- filter_def.atlas: atlas for the icon,  can be a string or function
-- filter_def.image: icon to show in the crafting menu, can be a string or function
-- filter_def.image_size: (optional) custom image sizing
-- filter_def.custom_pos: (optional) This will not be added to the grid of filters
-- filter_def.recipes: !This is not supported! Create the filter and then pass in the filter to AddRecipe2() or AddRecipeToFilter()
AddRecipeFilter({
    name = "NAUTICAL",
    atlas = "images/hud/pl_crafting_menu_icons.xml",
    image = "filter_nautical.tex",
}, #CRAFTING_FILTER_DEFS) -- insert this before the "all recipes" category

AddRecipeFilter({
    name = "ARCHAEOLOGY",
    atlas = "images/hud/pl_crafting_menu_icons.xml",
    image = "filter_archaeology.tex",
}, #CRAFTING_FILTER_DEFS)

AddRecipeFilter({
    name = "ENVIRONMENT_PROTECTION",
    atlas = "images/hud/pl_crafting_menu_icons.xml",
    image = "filter_environment_protection.tex",
}, #CRAFTING_FILTER_DEFS)

--- ARCHAEOLOGY ---
AddRecipe2("disarming_kit", {Ingredient("iron", 2), Ingredient("cutreeds", 2)}, TECH.NONE, {}, {"ARCHAEOLOGY"})
AddRecipe2("ballpein_hammer", {Ingredient("iron", 2), Ingredient("twigs", 1)}, TECH.SCIENCE_ONE, {}, {"ARCHAEOLOGY"})
AddRecipe2("goldpan", {Ingredient("iron", 2), Ingredient("hammer", 1)}, TECH.SCIENCE_ONE, {}, {"ARCHAEOLOGY"})
AddRecipe2("magnifying_glass", {Ingredient("iron", 1), Ingredient("twigs", 1), Ingredient("bluegem", 1)}, TECH.SCIENCE_TWO, {}, {"ARCHAEOLOGY"})

--SCIENCE
AddRecipe2("smelter", {Ingredient("cutstone", 6), Ingredient("boards", 4), Ingredient("redgem", 1)}, TECH.SCIENCE_TWO, {placer = "smelter_placer"}, {"TOOLS","STRUCTURES"})
SortBefore("smelter", "cookpot", "STRUCTURES")
SortAfter("smelter", "archive_resonator_item", "TOOLS")

AddRecipe2("basefan", {Ingredient("alloy", 2), Ingredient("transistor", 2), Ingredient("gears", 1)}, TECH.SCIENCE_TWO, {placer = "basefan_placer"}, {"STRUCTURES", "RAIN", "ENVIRONMENT_PROTECTION"})
SortBefore("basefan", "firesuppressor", "STRUCTURES")
SortBefore("basefan", "rainometer", "RAIN")

--TOOLS
AddRecipe2("bugrepellent", {Ingredient("tuber_crop", 6), Ingredient("venus_stalk", 1)}, TECH.SCIENCE_ONE, {}, {"TOOLS", "ENVIRONMENT_PROTECTION"})
SortAfter("bugrepellent", nil, "TOOLS")

AddRecipe2("machete", {Ingredient("twigs", 1),Ingredient("flint", 3)}, TECH.SCIENCE_ONE, {}, {"TOOLS"})
SortAfter("machete", "axe", "TOOLS")

AddRecipe2("goldenmachete", {Ingredient("twigs", 4),Ingredient("goldnugget", 2)}, TECH.SCIENCE_ONE, {}, {"TOOLS"})
SortAfter("goldenmachete", "goldenaxe", "TOOLS")

AddRecipe2("shears", {Ingredient("twigs", 2),Ingredient("iron", 2)}, TECH.SCIENCE_ONE, {}, {"TOOLS"})
SortAfter("shears", "goldenpitchfork", "TOOLS")

--WAR
AddRecipe2("blunderbuss", {Ingredient("boards", 2), Ingredient("oinc10", 1), Ingredient("gears", 1)}, TECH.SCIENCE_TWO, {}, {"WEAPONS"})
SortAfter("blunderbuss", "blowdart_sleep", "WEAPONS")

AddRecipe2("cork_bat", {Ingredient("cork", 3), Ingredient("boards", 1)}, TECH.SCIENCE_ONE, {}, {"WEAPONS"})
SortBefore("cork_bat", "hambat", "WEAPONS")

AddRecipe2("halberd", {Ingredient("alloy", 1), Ingredient("twigs", 2)}, TECH.SCIENCE_TWO, {}, {"WEAPONS", "TOOLS"})
SortAfter("halberd", "spear", "WEAPONS")
SortAfter("halberd", "shears", "TOOLS")

AddRecipe2("metalplatehat", {Ingredient("alloy", 3), Ingredient("cork", 3)}, TECH.SCIENCE_ONE, {}, {"ARMOUR"})
SortBefore("metalplatehat", "cookiecutterhat", "ARMOUR")

AddRecipe2("armor_metalplate", {Ingredient("alloy", 3), Ingredient("hammer", 1)}, TECH.SCIENCE_ONE, {}, {"ARMOUR"})
SortAfter("armor_metalplate", "armormarble", "ARMOUR")

AddRecipe2("armor_weevole", {Ingredient("weevole_carapace", 4), Ingredient("chitin", 2)}, TECH.SCIENCE_TWO, {}, {"ARMOUR", "RAIN", "ENVIRONMENT_PROTECTION"})
SortBefore("armor_weevole", "armorwood", "ARMOUR")
SortBefore("armor_weevole", "raincoat", "RAIN")

AddRecipe2("armorvortexcloak", {Ingredient("ancient_remnant", 5), Ingredient("armor_sanity", 1)}, TECH.LOST, {}, {"ARMOUR", "CLOTHING", "CONTAINERS", "MAGIC"})
SortAfter("armorvortexcloak", "dreadstonehat", "ARMOUR")
SortAfter("armorvortexcloak", "icepack", "CLOTHING")
SortAfter("armorvortexcloak", "spicepack", "CONTAINERS")
SortAfter("armorvortexcloak", "dreadstonehat", "MAGIC")

AddRecipe2("living_artifact", {Ingredient("infused_iron", 6), Ingredient("waterdrop", 1)}, TECH.LOST, {}, {"MAGIC", "ARMOUR", "WEAPONS"})
SortAfter("living_artifact", "nightmarefuel", "MAGIC")
SortAfter("living_artifact", nil, "ARMOUR")
SortAfter("living_artifact", nil, "WEAPONS")

--CLOTHING
AddRecipe2("antmaskhat", {Ingredient("chitin", 5),Ingredient("footballhat", 1)}, TECH.SCIENCE_ONE, {}, {"ARMOUR", "CLOTHING"})
SortAfter("antmaskhat", "footballhat", "ARMOUR")
SortAfter("antmaskhat", "bushhat", "CLOTHING")

AddRecipe2("antsuit", {Ingredient("chitin", 5),Ingredient("armorwood", 1)}, TECH.SCIENCE_ONE, {}, {"ARMOUR", "CLOTHING"})
SortAfter("antsuit", "armorwood", "ARMOUR")
SortAfter("antsuit", "antmaskhat", "CLOTHING")

AddRecipe2("bathat", {Ingredient("pigskin", 2), Ingredient("batwing", 1), Ingredient("compass", 1)}, TECH.SCIENCE_TWO, {}, {"LIGHT", "ENVIRONMENT_PROTECTION"})
SortAfter("bathat", "molehat", "LIGHT")

AddRecipe2("candlehat", {Ingredient("cork", 4), Ingredient("iron", 2)}, TECH.SCIENCE_ONE, {}, {"LIGHT", "RAIN"})
SortBefore("candlehat", "coldfirepit", "LIGHT")
SortBefore("candlehat", "tophat", "RAIN")

AddRecipe2("snakeskinhat", {Ingredient("snakeskin", 1, nil, nil, "snakeskin_scaly.tex"), Ingredient("strawhat", 1), Ingredient("boneshard", 1)}, TECH.SCIENCE_TWO, {image = "snakeskinhat_scaly.tex"}, {"CLOTHING", "RAIN"})
SortBefore("snakeskinhat", "earmuffshat", "CLOTHING")
SortAfter("snakeskinhat", "rainhat", "RAIN")

AddRecipe2("armor_snakeskin", {Ingredient("snakeskin", 2, nil, nil, "snakeskin_scaly.tex"), Ingredient("vine", 2), Ingredient("boneshard", 2)}, TECH.SCIENCE_ONE, {image = "armor_snakeskin_scaly.tex"}, {"CLOTHING", "RAIN"})
SortBefore("armor_snakeskin", "sweatervest", "CLOTHING")
SortAfter("armor_snakeskin", "raincoat", "RAIN")

AddRecipe2("gasmaskhat", {Ingredient("peagawkfeather", 4), Ingredient("pigskin", 1), Ingredient("fabric", 1)}, TECH.SCIENCE_TWO, {}, {"CLOTHING", "ENVIRONMENT_PROTECTION"})
SortAfter("gasmaskhat", "icehat", "CLOTHING")

AddRecipe2("thunderhat", {Ingredient("feather_thunder", 1), Ingredient("goldnugget", 1),Ingredient("cork", 2)}, TECH.SCIENCE_TWO, {}, {"CLOTHING", "RAIN","ENVIRONMENT_PROTECTION"})
SortAfter("thunderhat", "pithhat", "CLOTHING")
SortAfter("thunderhat", "eyebrellahat", "RAIN")

AddRecipe2("pithhat", {Ingredient("fabric", 1),Ingredient("vine", 3),Ingredient("cork", 6)}, TECH.SCIENCE_TWO, {}, {"CLOTHING", "RAIN", "ENVIRONMENT_PROTECTION"})
SortAfter("pithhat", "thunderhat", "CLOTHING")
SortAfter("pithhat", "thunderhat", "RAIN")

--MAGIC
AddRecipe2("hogusporkusator", {Ingredient("pigskin", 4), Ingredient("boards", 4), Ingredient("feather_robin_winter", 4)}, TECH.SCIENCE_ONE, {placer = "hogusporkusator_placer"}, {"MAGIC", "STRUCTURES", "PROTOTYPERS"})
SortAfter("hogusporkusator", "researchlab4", "MAGIC")
SortAfter("hogusporkusator", "researchlab4", "STRUCTURES")
SortAfter("hogusporkusator", "researchlab4", "PROTOTYPERS")

AddRecipe2("bonestaff", {Ingredient("pugalisk_skull", 1), Ingredient("boneshard", 1), Ingredient("nightmarefuel", 2)}, TECH.MAGIC_THREE, {} , {"WEAPONS","MAGIC"})
SortAfter("bonestaff", "antlionhat", "MAGIC")
SortAfter("bonestaff", "trident", "WEAPONS")

--REFINE
AddRecipe2("goldnugget", {Ingredient("gold_dust", 6)}, TECH.SCIENCE_ONE, {no_deconstruction = true} , {"REFINE"})
AddRecipe2("clawpalmtree_sapling_item", {Ingredient("cork", 1), Ingredient("poop", 1)}, TECH.SCIENCE_ONE, {no_deconstruction = true, image = "clawpalmtree_sapling.tex"}, {"REFINE"})
AddRecipe2("venomgland", {Ingredient("froglegs_poison", 3)}, TECH.SCIENCE_TWO, {no_deconstruction = true} , {"REFINE"})

--DECOR
-- AddRecipe2("turf_foundation", {Ingredient("cutstone", 1)}, TECH.CITY, cityRecipeGameTypes, nil, nil, true)
-- AddRecipe2("turf_cobbleroad", {Ingredient("cutstone", 2), Ingredient("boards", 1)}, TECH.CITY, cityRecipeGameTypes, nil, nil, true)
-- AddRecipe2("turf_lawn", {Ingredient("cutgrass", 2), Ingredient("nitre", 1)}, TECH.SCIENCE_TWO)
-- AddRecipe2("turf_fields", {Ingredient("turf_rainforest", 1), Ingredient("ash", 1)}, TECH.SCIENCE_TWO)
-- AddRecipe2("turf_deeprainforest_nocanopy", {Ingredient("bramble_bulb", 1), Ingredient("cutgrass", 2), Ingredient("ash", 1)}, TECH.SCIENCE_TWO)

--NAUTICAL
AddRecipe2("boat_lograft", {Ingredient("log", 6), Ingredient("cutgrass", 4)}, TECH.NONE, {placer = "boat_lograft_placer", build_mode = BUILDMODE.WATER, build_distance = 4}, {"NAUTICAL"})
AquaticRecipe("boat_lograft", {distance = 4, platform_buffer_min = 2, aquatic_buffer_min = 1, boat = true})

AddRecipe2("boat_row", {Ingredient("boards", 3), Ingredient("vine", 4)}, TECH.SCIENCE_ONE, {placer = "boat_row_placer", build_mode = BUILDMODE.WATER, build_distance = 4}, {"NAUTICAL"})
AquaticRecipe("boat_row", {distance = 4, platform_buffer_min = 2, aquatic_buffer_min = 1, boat = true})

AddRecipe2("boat_cork", {Ingredient("cork", 4), Ingredient("rope", 1)}, TECH.SCIENCE_ONE, {placer = "boat_cork_placer", build_mode = BUILDMODE.WATER, build_distance = 4}, {"NAUTICAL"})
AquaticRecipe("boat_cork", {distance = 4, platform_buffer_min = 2, aquatic_buffer_min = 1, boat = true})

AddRecipe2("boat_cargo", {Ingredient("boards", 6), Ingredient("rope", 3)}, TECH.SCIENCE_ONE, {placer = "boat_cargo_placer", build_mode = BUILDMODE.WATER, build_distance = 4}, {"NAUTICAL"})
AquaticRecipe("boat_cargo", {distance = 4, platform_buffer_min = 2, aquatic_buffer_min = 1, boat = true})

AddRecipe2("boatrepairkit", {Ingredient("boards", 2), Ingredient("stinger", 2), Ingredient("rope", 2)}, TECH.SCIENCE_ONE, nil, {"NAUTICAL"})

AddRecipe2("boat_torch", {Ingredient("twigs", 2), Ingredient("torch", 1)}, TECH.SCIENCE_ONE, nil, {"LIGHT", "NAUTICAL"})

AddRecipe2("sail_snakeskin", {Ingredient("log", 4), Ingredient("rope", 2), Ingredient("snakeskin", 2, nil, nil, "snakeskin_scaly.tex")}, TECH.SCIENCE_TWO, {image = "sail_snakeskin_scaly.tex"}, {"NAUTICAL"})

--CHARACTER

AddRecipe2("disguisehat", {Ingredient("twigs", 2), Ingredient("pigskin", 1), Ingredient("beardhair", 1)}, TECH.NONE, {builder_tag = "spiderwhisperer"}, {"CHARACTER", "CLOTHING"})
SortBefore("disguisehat", "spidereggsack", "CHARACTER")

AddRecipe2("poisonbalm", {Ingredient("livinglog", 1), Ingredient("venomgland", 1)}, TECH.NONE, {builder_tag = "plantkin"}, {"CHARACTER", "RESTORATION"})
SortAfter("poisonbalm", "armor_bramble", "CHARACTER")
SortBefore("poisonbalm", "healingsalve", "RESTORATION")

local function IsValidSprinklerTile(tile)
    return not TileGroupManager:IsOceanTile(tile) and (tile ~= WORLD_TILES.INVALID) and (tile ~= WORLD_TILES.IMPASSABLE)
end

local function GetValidWaterPointNearby(pt)
    local range = 20

    local cx, cy = TheWorld.Map:GetTileCoordsAtPoint(pt.x, 0, pt.z)
    local center_tile = TheWorld.Map:GetTile(cx, cy)

    local min_sq_dist = 999999999999
    local best_point = nil

    for x = pt.x - range, pt.x + range, 1 do
        for z = pt.z - range, pt.z + range, 1 do
            local tx, ty = TheWorld.Map:GetTileCoordsAtPoint(x, 0, z)
            local tile = TheWorld.Map:GetTile(tx, ty)

            if IsValidSprinklerTile(center_tile) and TileGroupManager:IsOceanTile(tile) then
                local cur_point = Vector3(x, 0, z)
                local cur_sq_dist = cur_point:DistSq(pt)

                if cur_sq_dist < min_sq_dist then
                    min_sq_dist = cur_sq_dist
                    best_point = cur_point
                end
            end
        end
    end

    return best_point
end

local function sprinkler_placetest(pt, rot)
    return GetValidWaterPointNearby(pt) ~= nil
end

AddRecipe2("sprinkler", {Ingredient("alloy", 2), Ingredient("bluegem", 1), Ingredient("ice", 6)}, TECH.SCIENCE_TWO, {placer = "sprinkler_placer", testfn = sprinkler_placetest}, {"GARDENING", "STRUCTURES"})

AddRecipe2("corkchest", {Ingredient("cork", 2), Ingredient("rope", 1)}, TECH.SCIENCE_ONE, {placer="corkchest_placer", min_spacing=1}, {"STRUCTURES", "CONTAINERS"})

AddRecipe2("roottrunk_child", {Ingredient("bramble_bulb", 1), Ingredient("venus_stalk", 2), Ingredient("boards", 3)}, TECH.MAGIC_TWO, {placer="roottrunk_child_placer", min_spacing=2}, {"STRUCTURES", "CONTAINERS", "MAGIC"})

--Deconstruct
AddDeconstructRecipe("mandrakehouse", {Ingredient("boards", 3), Ingredient("mandrake", 2), Ingredient("cutgrass", 10)})
