local tint = {r = 1, g = 1, b = 0}
--make the entity
local ArtilleryCombinatorEntity = util.table.deepcopy(data.raw["constant-combinator"]["constant-combinator"]);
ArtilleryCombinatorEntity.name = "artillery-combinator"
ArtilleryCombinatorEntity.item_slot_count = 0
ArtilleryCombinatorEntity.order = "a[MapPing]"
ArtilleryCombinatorEntity.minable.result = "artillery-combinator"
for k, direction in pairs(ArtilleryCombinatorEntity.sprites) do
  for kk, vv in pairs(direction.layers) do
    vv.tint = tint
  end
end
data:extend({ArtilleryCombinatorEntity})

--make the item
local ArtilleryCombinatorItem = util.table.deepcopy(data.raw["item"]["constant-combinator"])
ArtilleryCombinatorItem.name = "artillery-combinator"
ArtilleryCombinatorItem.place_result = "artillery-combinator"
ArtilleryCombinatorItem.icons = {{icon = ArtilleryCombinatorItem.icon, icon_size = ArtilleryCombinatorItem.icon_size, tint = tint}}
ArtilleryCombinatorItem.icon = nil
data:extend({ArtilleryCombinatorItem})

--make the recipe
local ArtilleryCombinatorRecipe = util.table.deepcopy(data.raw.recipe["constant-combinator"])
ArtilleryCombinatorRecipe.name = "artillery-combinator"
--table.insert(ArtilleryCombinatorRecipe.ingredients, {"artillery-targeting-remote", 1})
ArtilleryCombinatorRecipe.results = {{type = "item", name = "artillery-combinator", amount = 1}}
data:extend({ArtilleryCombinatorRecipe})

--add the recepe to the "circuit network" technology
table.insert(data.raw.technology["artillery"].effects, {
  type = "unlock-recipe",
  recipe = "artillery-combinator"
})

data:extend({
  {
    type = "custom-input",
    name = "artillerycombinator-shame-and-regret",
    key_sequence = "PAUSE",
    consuming = "none"
  }
})