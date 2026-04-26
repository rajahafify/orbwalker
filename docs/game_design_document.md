# Matchatro Game Design Document

Status: Draft 0.1  
Title: Temporary  
Genre: Match-3 roguelike  
Target platforms: PC and mobile  
Primary inputs: Mouse and touch

## High Concept

Matchatro is a fantasy match-3 roguelike where the free orb movement of Puzzle & Dragons / Tower of Saviors meets Balatro-style run progression, shops, boosters, equipment, mastery cards, consumables, and relics.

The player controls a single hero through a run of dungeon levels. Each fight is turn-based. The player moves one orb freely across a 5x6 board under a short timer, creates matches, resolves cascades, and uses the resulting damage, healing, armor, and gold to survive the run.

## Design Pillars

1. Free movement puzzle combat: the player can drag one orb through the board, displacing other orbs as it moves.
2. Build-driven roguelike progression: equipment, mastery, consumables, and relics change scoring, economy, defense, and orb value.
3. Clear enemy intent: each turn, the player sees what the enemy is about to do and plans the board movement around that threat.
4. Short, readable decisions: each fight should be understandable at a glance, but high skill should come from routing the board under time pressure.
5. Fantasy first: items should feel like recognizable fantasy gear, relics, and magic rather than abstract casino objects.

## Player Fantasy

The player is a fantasy hero fighting through a dungeon by manipulating elemental orbs. The hero grows stronger through equipment and mastery rather than party members.

Future versions may add multiple hero types. Each hero may have different equipment pools, mastery unlocks, starting stats, or passive rules. The first version uses one generic hero.

## Core Game Loop

### Fight Loop

1. Enemy intent is shown.
2. Player starts dragging an orb.
3. The 5-second movement timer starts.
4. Player releases the mouse/touch, or the timer ends.
5. All matches resolve.
6. New orbs fall from the top.
7. Cascades continue until no matches remain.
8. Player effects resolve in this order:
   1. Heart healing.
   2. Armor gain.
   3. Elemental damage.
   4. Gold gain.
9. If the enemy dies, its attack does not resolve.
10. If the enemy survives, its intent resolves.
11. Temporary armor expires.
12. Next turn begins.

### Dungeon Level Loop

The target full run uses 10 dungeon levels.

Each dungeon level follows this structure:

1. Enemy 1.
2. Shop.
3. Enemy 2.
4. Shop.
5. Boss.
6. Boss relic reward.
7. Shop.
8. Advance to the next dungeon level.

Level 10 ends with the main boss.

### Run Loop

1. Start a run.
2. Pick a dungeon.
3. Clear dungeon levels.
4. Build around equipment, mastery, consumables, relics, and gold income.
5. Die or defeat the level 10 main boss.
6. Unlock future equipment and relics through meta progression.

Only one dungeon is required for the first version. Additional dungeons and ascension-style difficulty can be added later.

## Board Rules

- Board size: 5 columns x 6 rows.
- Gravity: down.
- Refill: new orbs enter from the top.
- Starting boards should avoid automatic matches.
- The board does not need to guarantee that a match is available.
- New orbs can immediately create cascades.
- Cascades count as real combos and trigger normal orb effects.

## Orb Movement

The orb movement is the Puzzle & Dragons style.

- The player selects one orb.
- Dragging the selected orb through adjacent cells swaps/displaces the orb in each cell it passes through.
- Movement is horizontal and vertical only.
- Diagonal movement is not allowed.
- The timer starts when the player begins dragging.
- The movement ends when the player releases input or when the 5-second timer expires.

## Match Rules

Only same-type orbs can match.

Valid match shapes:

- Straight horizontal line of 3 or more.
- Straight vertical line of 3 or more.
- L shape made from connected horizontal and vertical same-type lines.
- T shape made from connected horizontal and vertical same-type lines.

Diagonal connections do not count.

## Orb Types

| Orb | Primary Effect | Default Value | Combo Scaling |
| --- | --- | ---: | --- |
| Fire | Damage | 1 damage per orb | Yes |
| Ice | Damage | 1 damage per orb | Yes |
| Earth | Damage | 1 damage per orb | Yes |
| Heart | Healing | 1 HP per orb | No |
| Armor | Defense | 1 armor per orb | No |
| Gold | Currency | 1 gold per orb | No |

Gold orbs are rarer than other orb types. Their exact spawn rate is a balance target.

## Damage And Resource Formula

Damage-scaling orb calculations (Fire, Ice, Earth, Armor):

```text
base_amount = orb_count * (orb_mastery_level + 1)
damage_combo_multiplier = (increase_combo_modifier + combo_count) * more_combo_modifier
total_amount = base_amount * damage_combo_multiplier
```

Non-combo orb calculations:

```text
heart_total = heart_orb_count * (heart_mastery_level + 1)
gold_total = gold_orb_count * (gold_mastery_level + 1)
```

Interpretation:

- `orb_mastery_level` is tracked per orb type.
- `increase_combo_modifier` is additive with combo count.
- `more_combo_modifier` is multiplicative after the additive stage ("increase then more" style).
- Heart and Gold explicitly do not use combo scaling.

Example:

```text
fire_orb_count = 3
fire_mastery_level = 0
increase_combo_modifier = 0
combo_count = 3
more_combo_modifier = 1

base_amount = 3 * (0 + 1) = 3
damage_combo_multiplier = (0 + 3) * 1 = 3
total_amount = 3 * 3 = 9
```

## Player Stats

Initial prototype target:

| Stat | Starting Value |
| --- | ---: |
| Max HP | 100 |
| Fire base value | 1 |
| Ice base value | 1 |
| Earth base value | 1 |
| Heart base value | 1 |
| Armor base value | 1 |
| Gold base value | 1 |
| Equipment slots | 5 |
| Consumable slots | 3 |
| Move timer | 5 seconds |

HP persists across the run.

Player armor behaves like Slay the Spire block:

- Armor reduces incoming enemy damage before HP.
- Unused armor expires after the enemy turn.
- A future relic may allow armor to last for 2 turns.

Healing is rare. There is no automatic healing after bosses.

## Enemy Rules

Enemies have HP only. They do not have persistent armor by default.

Each enemy has a moveset that cycles through intents. Intent is visible before the player moves.

Initial enemy intents:

- Attack: deal damage to the player.
- Block: reduce incoming player damage this turn.
- Attack + Block: reduce incoming player damage this turn, then attack if still alive.

If an enemy intent includes block, that block applies against the player's damage on the current turn. The enemy block does not persist after the turn unless a future enemy rule says otherwise.

If the enemy dies from player damage, its remaining intent does not resolve.

Enemies will scale through:

- HP scaling.
- Damage scaling.
- Block scaling.
- More punishing moveset cycles.
- Boss checks.

Level 1 normal enemies should be killable in roughly 3 turns by an expert player while taking minimal damage.

## Boss Rules

Boss type should be visible at the start of the dungeon level.

Bosses should mostly act as checks on the player's build and execution. Examples:

- Defense check: boss deals high damage every turn.
- Damage check: boss gains large block every turn.
- Combo check: boss reduces damage unless the player reaches a combo threshold.
- Element check: boss is immune to certain elements on certain turns.
- Scaling check: boss grows stronger every few turns.

Bosses should feel like Slay the Spire elites/bosses: readable, threatening, and capable of punishing slow builds.

## Economy

Gold persists for the whole run.

Gold is primarily earned by matching gold orbs. Normal enemies do not need to drop gold after death.

Equipment, mastery, relics, and other effects can improve gold income.

After defeating a normal enemy, the player receives no automatic reward other than gold they matched during the fight.

## Shop

The player automatically enters the shop after each fight and can skip by buying nothing.

Default shop inventory:

- 3 random item slots.
- 1 relic offer for the current dungeon level.

Random item slots can contain:

- Equipment.
- Mastery cards.
- Boosters.
- Consumables.

Relic rules:

- One relic can appear as the shop relic offer per dungeon level.
- If not bought, that relic offer is lost.
- Bosses also grant a relic reward.
- Therefore, a dungeon level can offer up to 2 relics: 1 shop relic and 1 boss relic reward.

Shop actions:

- Buy items.
- Buy multiple boosters if the player has enough gold.
- Reroll shop inventory.
- Sell equipment for full gold value.

Pricing rules:

- Prices scale by rarity.
- Prices may scale by dungeon level.
- After killing the first enemy, the player should usually be able to afford at least 1 booster pack if they matched some gold.

## Boosters

Boosters work like Balatro booster packs.

The player buys a pack, opens it, sees 3 generated options, and picks 1.

Booster types:

- Element booster: generates items tied to a specific orb type, such as Fire, Ice, Earth, Heart, Armor, or Gold.
- Category booster: generates items from a category, such as 3 equipment, 3 mastery cards, or 3 consumables.

Boosters can produce:

- Equipment.
- Mastery cards.
- Consumables.

Relics are not part of normal booster pools unless a specific future pack allows it.

## Equipment

Equipment is the Balatro joker equivalent.

Rules:

- Equipment is passive.
- Equipment has rarity.
- The hero starts with 5 equipment slots.
- Relics can add more slots.
- Duplicate equipment is not allowed.
- Equipment can be sold for full gold value.
- Equipment is not hero-specific in the first version.
- Future rare equipment may have downside effects.

Equipment should mainly modify:

- Base orb values.
- Damage formula.
- Combo multiplier.
- Armor gain.
- Healing value.
- Gold gain.
- Mastery level while equipped.

Equipment should feel like normal fantasy gear: shortsword, buckler, charm, ring, amulet, boots, cloak, etc.

## Mastery

Mastery cards are the Balatro planet card equivalent.

Rules:

- Mastery is permanent for the current run.
- Each orb type has a mastery card.
- Mastery has a max level.
- Working prototype cap: level 5.
- Working formula: orb base value = 1 + mastery level.
- Equipment can temporarily add mastery levels while equipped.

Initial mastery cards:

| Mastery | Effect |
| --- | --- |
| Fire Mastery | Fire orbs gain +1 damage per orb per level. |
| Ice Mastery | Ice orbs gain +1 damage per orb per level. |
| Earth Mastery | Earth orbs gain +1 damage per orb per level. |
| Heart Mastery | Heart orbs heal +1 HP per orb per level. |
| Armor Mastery | Armor orbs give +1 armor per orb per level. |
| Gold Mastery | Gold orbs give +1 gold per orb per level. |

Example:

```text
Fire Mastery level 1:
fire base value = 2

3 fire orbs, 3 total combos:
3 * 2 * 3 = 18 fire damage
```

## Consumables

Consumables are single-use items.

Rules:

- The player has 3 consumable slots.
- Consumables can be held for later.
- Consumables mainly affect the board.
- Consumables can be bought, found from boosters, or possibly earned from future rewards.

Initial consumable direction:

- Remove a specific orb type.
- Convert one orb type into another.
- Add a small number of specific orbs.
- Clean up the board before a difficult enemy turn.

## Relics

Relics are rare run modifiers.

Rules:

- Relics last for the whole run.
- Relics are run-changing and limited.
- One relic can be offered in the shop per dungeon level.
- One relic can be obtained after killing each boss.
- Meta progression can unlock new relics.

Relics should be stronger and broader than equipment. Examples:

- Add an equipment slot.
- Let armor last 2 turns.
- Increase gold orb spawn rate.
- Improve all boosters.
- Change how combo multiplier scales.

## Meta Progression

Meta progression should unlock content, not raw permanent power.

Initial meta progression:

- Unlock new equipment.
- Unlock new relics.

Future meta progression:

- Unlock hero types.
- Unlock dungeons.
- Unlock ascension levels.
- Unlock advanced mastery cards.

## First Playable Prototype Scope

Recommended vertical slice:

- 3 dungeon levels instead of the full 10.
- One hero.
- All 6 orb types.
- 5x6 board.
- Free orb movement.
- 5-second timer.
- Same-type line, L, and T matching.
- Cascades.
- Enemy intent.
- Player HP persistence.
- Armor expiration after enemy turn.
- Gold economy.
- Shop after each fight.
- 3 random shop item slots.
- 1 shop relic offer per dungeon level.
- Boss relic reward.
- 5 equipment slots.
- 3 consumable slots.
- 6 mastery cards.
- 6 consumables.
- 20 to 30 equipment items.
- 5 relics.
- At least 3 normal enemies and 3 bosses.

## Initial Equipment List

These are prototype effects and need balance passes.

| Equipment | Rarity | Effect |
| --- | --- | --- |
| Shortsword | Common | If at least one damage orb matches, add +5 final damage. |
| Buckler | Common | First armor match each turn gives +5 armor. |
| Coin Purse | Common | Gold orbs give +1 gold per orb. |
| Healing Charm | Common | First heart match each turn restores +4 HP. |
| Ember Ring | Common | Fire base value +1. |
| Frost Ring | Common | Ice base value +1. |
| Stone Ring | Common | Earth base value +1. |
| Leather Gloves | Common | Move timer +0.5 seconds. |
| Iron Helm | Common | Start each fight with 5 armor. |
| Combo Lens | Common | If total combo count is 3 or higher, combo count is treated as +1 for damage. |
| Twin Blades | Uncommon | If Fire and Ice both match, add +12 final damage. |
| War Banner | Uncommon | First damage match each turn gains +1 base value. |
| Tower Shield | Uncommon | Armor base value +1. |
| Merchant Scales | Uncommon | First gold match each turn gives +5 extra gold. |
| Battle Drum | Uncommon | If total combo count is 5 or higher, multiply damage by 1.25. |
| Earthbreaker Maul | Uncommon | Earth damage ignores the first 10 enemy block. |
| Hearth Amulet | Uncommon | Heart base value +1. |
| Alchemist Gloves | Uncommon | Using a consumable also creates 2 gold orbs. |
| Training Manual | Uncommon | All mastery levels count as +1 while equipped. |
| Mirror Charm | Uncommon | The first mastery card bought each dungeon level is copied. |
| Ruby Brooch | Rare | Fire Mastery counts as level 5 while equipped. |
| Sapphire Brooch | Rare | Ice Mastery counts as level 5 while equipped. |
| Emerald Brooch | Rare | Earth Mastery counts as level 5 while equipped. |
| Royal Seal | Rare | Gold base value +2. |
| Champion Plate | Rare | Player armor lasts until the start of the next player turn instead of expiring immediately after enemy action. |

## Initial Mastery Cards

| Card | Type | Effect |
| --- | --- | --- |
| Fire Mastery | Mastery | Increase Fire Mastery by 1, up to cap. |
| Ice Mastery | Mastery | Increase Ice Mastery by 1, up to cap. |
| Earth Mastery | Mastery | Increase Earth Mastery by 1, up to cap. |
| Heart Mastery | Mastery | Increase Heart Mastery by 1, up to cap. |
| Armor Mastery | Mastery | Increase Armor Mastery by 1, up to cap. |
| Gold Mastery | Mastery | Increase Gold Mastery by 1, up to cap. |

## Initial Consumables

| Consumable | Type | Effect |
| --- | --- | --- |
| Fire Scroll | Consumable | Convert 5 random non-Fire orbs into Fire orbs. |
| Ice Scroll | Consumable | Convert 5 random non-Ice orbs into Ice orbs. |
| Earth Scroll | Consumable | Convert 5 random non-Earth orbs into Earth orbs. |
| Heart Scroll | Consumable | Convert 5 random non-Heart orbs into Heart orbs. |
| Armor Scroll | Consumable | Convert 5 random non-Armor orbs into Armor orbs. |
| Gold Scroll | Consumable | Convert 3 random non-Gold orbs into Gold orbs. |

## Initial Relics

| Relic | Effect |
| --- | --- |
| Deep Pockets | Gain +1 equipment slot. |
| Stalwart Mantle | Player armor lasts for 2 turns. |
| Golden Idol | Gold orbs appear more often. |
| Crown of Chains | Every combo after the fifth adds +2 to the damage combo count instead of +1. |
| Merchant Compass | First shop reroll each shop is free. |

## Initial Enemy Direction

Normal enemies should use simple readable cycles.

Example enemy patterns:

| Enemy Pattern | Turn 1 | Turn 2 | Turn 3 |
| --- | --- | --- | --- |
| Striker | Attack 8 | Attack 10 | Block 8 |
| Defender | Block 12 | Attack 8 + Block 8 | Attack 12 |
| Charger | Block 10 | Attack 6 | Attack 18 |

## Initial Boss Direction

Bosses should preview their type before the dungeon level begins.

Example boss checks:

| Boss Type | Rule |
| --- | --- |
| Iron Gate | Starts each turn with high block. Tests damage output. |
| Burning Knight | Deals high damage every turn. Tests armor and healing. |
| Prism Warden | Rotates elemental immunity each turn. Tests flexible damage. |
| Combo Gate | Reduces damage unless the player reaches a combo threshold. |
| Rising Blade | Gains damage every 3 turns. Tests speed. |

## Future Ideas

Future elemental identity:

- Fire can apply damage over time.
- Ice can build stagger and freeze when full.
- Earth can add defense or interact with armor.

Future systems:

- Debuff enemy intents.
- Hazard orbs.
- Locked orbs.
- Advanced boss rules.
- Multiple heroes.
- More dungeons.
- Ascension levels.
- Equipment with tradeoffs.
- Relics that alter match rules.

## Open Balance Questions

- Exact gold orb spawn rate.
- Exact mastery level cap.
- Shop price ranges by rarity and dungeon level.
- Reroll cost curve.
- Starting HP.
- Level 1 enemy HP and damage.
- Boss HP and scaling curve.
- Whether full runs should remain 10 dungeon levels or be shortened after playtesting.
- Whether 5 seconds is the right default movement timer for both PC and mobile.
- Whether L/T matching should produce bonus effects beyond counting connected matched orbs.
