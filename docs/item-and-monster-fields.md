# Item and monster attributes

The C64 bytes are authoritative. Comparisons use the files supplied in
`additional/`, without downloading anything. The saved Bard's Tale Online
**Item Catalogue** lists item IDs, categories, damage, AC reductions, class
permissions, spells, and effects. `BT3-Items.xls` is a useful second reference,
but explicitly calls its damage figures experiential and strength-dependent:
its Broadsword damage is 1–10, whereas the catalogue and C64 dice give 2–8.
Do not substitute spreadsheet ranges for encoded C64 damage.

## Item property arrays

All seven arrays use item ID as the index; index zero is not exported. JSON
schema 2 uses the names below in `properties`, with original table addresses
retained once in `property_sources`. These are original bytes; decoded fields
are additional views, so packed bits are never discarded.

| JSON property | C64 base | Meaning / evidence |
| --- | --- | --- |
| `maximum_charges` | `$e273` | Charge limit; 255 is nondepleting. Loot generation at `$af60` randomizes finite counts; exhaustion at `$70e8` checks for one-use items. |
| `melee_damage_dice` | `$e373` | Passed through `$7924` to `$ac74/$fa5a`: low five bits + 1 dice, sides from `$cd68[high3]+1`. |
| `armor_and_damage_bonus` | `$e473` | Low nibble: AC reduction (`$fc56`). High nibble: melee damage bonus (`$ab6a`). |
| `type_and_attack_effect` | `$e573` | Low nibble: item category, decoded from the game's own category-name pointers at `$7009`. High nibble: attack-effect selector (`$ab64`). |
| `usable_classes_mask` | `$e673` | ANDed with class masks at `$d987` by `$7189`. Several classes share bits. |
| `equipped_effect` | `$e773` | Low nibble is an equipped-effect selector checked by `$6f9e` and returned for instruments by `$6fd6`; full upper-bit meaning unresolved. |
| `use_effect_id` | `$e873` | Catalogue correlation: Torch 126, Lamp 127, thrown weapons 131, figurines 132, Fire Horn 133; 255 means no use effect. Spell/special ID namespace, not damage or price. Complete dispatch mapping remains unresolved. |

Examples corroborated by the catalogue: Broadsword `$21` = 2d4 (2–8),
Short Sword `$40` = 1d8, War Axe `$21` = 2d4, Mthr Sword `$21/$20` =
2d4+2, Shield Staff `$60/$12` = 1d16+1 with AC-2. Leather Armor's
bonus byte 2 means AC-2, and Chain Mail's 3 means AC-3. A zero dice byte
encodes 1d2; it is not a missing-value flag. Non-weapons receive null
`melee_damage`, since the presence of a table byte does not make them weapons.
Damage describes the weapon roll plus its item bonus; strength, class,
spells, critical hits, and other combat adjustments are separate.

The attack-effect and equipped-effect codes remain numeric. The references
mention poisoning, stoning, critical hits, regeneration, and other abilities,
but do not establish every C64 selector value or bit. No strength attribute
has been identified in these seven item tables.

## Monster records

`BT3-Monsters.pdf` is explicitly a monster-name list from the MS-DOS version.
`BT3_Monster.pdf` groups monsters by appearance and gives location codes. It
helps explain shared portraits and repeated names, but supplies no strength,
AC, damage, or byte-offset table. `BT3-Spells.pdf` describes spells; it does
not establish the C64 monster record layout or numeric spell-ID mapping.
Names alone are insufficient to assign another platform's statistics.

The exporter additionally exposes fields established by the C64 code:

| Field | Record offset | Evidence |
| --- | --- | --- |
| `hit_points` | `$10..$12` | Dice at `$10` plus little-endian bonus `$11/$12`; `$fa3b/$fa5a`, saturation at 65535. |
| `distance` | `$13` | Low nibble current distance, high nibble advance amount; `$a053/$a0af`, in 10-foot units. |
| `initial_group_count_low5` | `$15` low five bits | `$a20f..$a233`, `$f9df`; high bits not renamed. |
| `actions` | `$16..$1d` | Four opcode/parameter pairs, chosen at `$9f2b..$9f3d`. Opcodes below 128 dispatch spells (`$9f5f`); `$f0..$f9` use the parameter as damage dice (`$ad83/$fa5a`). Other special-action parameters remain raw. |
| `portrait_resource_id` | `$20` | `$b377..$b37c` passes this byte to `$68c9`, the picture-pair loader. |

`actions[].damage` is the base physical attack roll, before combat modifiers;
`attack_effect_code` retains the numeric physical attack subtype. Both original
`action_descriptors` and all 48 `raw_bytes` remain available. The action evidence
previously cited `$9c89`, which reads a converted party/summon record at `$54`;
the direct monster-record selector is `$9f2b` at `$16`.

Only items and monsters move to schema 2. Other exported documents keep schema
1. Regenerate comments through `tools/game_analysis.py` and exports with
`make extract`; do not edit generated JSON independently.
