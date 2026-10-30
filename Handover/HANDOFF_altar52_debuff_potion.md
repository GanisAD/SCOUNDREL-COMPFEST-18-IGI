# 🔀 Handoff: ALTAR-52 — Debuff & Potion System

> **Project:** ALTAR-52 (Scoundrel Roguelike Card Game)
> **Engine:** Godot 4.7.2 (GL Compatibility)
> **Branch / Worktree:** `implement_debuffs_and_potions`
> **Workspace Root:** `/home/ganis/.gemini/antigravity/worktrees/SCOUNDREL-COMPFEST-18-IGI/implement_debuffs_and_potions`
> **Upstream Repo:** `/home/ganis/Documents/Game-Project/Godot/SCOUNDREL-COMPFEST-18-IGI`
> **Created:** 2026-10-26T20:57+07:00
> **Prior Conversation:** [463b8bb8-6ec4-4f9f-9488-9b448c0469bf](conversation://463b8bb8-6ec4-4f9f-9488-9b448c0469bf)

---

## 1 · Goal

Integrate a **Potion** system (heal, block, utility consumables) and a **Debuff** system (trade-off curses applied via Spade/Blood-Exchange rooms) into the game loop. Debuffs are stored as inventory items with a battle-count duration, passively modifying `CharacterStats` at the start of each combat and expiring after N battles.

---

## 2 · What Is Done (✅)

### 2.1 Modular Effect Component — `Script/Effect/`

Effects were extracted from `Script/Card/Effect/` to `Script/Effect/` so **Card**, **Potion**, and future systems can share them without duplication.

| File | Class | Purpose |
|---|---|---|
| `effect.gd` | `Effect` | Abstract base; defines `execute(targets, player)` |
| `damageEffect.gd` | `DamageEffect` | Deals calculated damage via `DamageCalculator` |
| `blockEffect.gd` | `blockEffect` | Adds `amount` block to player |
| `health_effect.gd` | `healthEffect` | Adds `amount` HP to player |
| `strenghtEffect.gd` | `StrengthEffect` | Adds strength stacks (self or target) |
| `weakendEffect.gd` | `WeakenedEffect` | Adds weakened stacks (target or self) |

All stale `res://Script/Card/Effect/…` paths in `.tres` files have been migrated to `res://Script/Effect/…`.

### 2.2 Potion System

- **`Script/Inventory/Item/potion_data.gd`** (`PotionData extends ItemData`)
  - `target_type: TargetType` enum (`SELF`, `SINGLE_ENEMY`, `ALL_ENEMIES`)
  - `effects: Array[Effect]`
  - `use(targets, player)` — iterates and executes all effects
- **Resources:**
  - `Data/Potion/heal_potion.tres` — restores 15 HP (`healthEffect`, amount=15)
  - `Data/Potion/block_potion.tres` — grants 12 Block (`blockEffect`, amount=12)
- Both are listed in `Data/Room/heart.tres` → `possible_item_pool`.

### 2.3 Debuff System (as Inventory Item)

- **`Script/Inventory/Item/debuff_data.gd`** (`DebuffData extends ItemData`)
  - `duration_in_battles: int` — how many combats the debuff survives
  - `max_hp_reduction_percent: float` — percentage of `max_health` to remove
  - `strength_bonus: int` — strength stacks granted as upside
  - `effects: Array[Effect]` — optional extra effect components
  - `apply_to_stats(stats: CharacterStats)` — reduces `max_health`, clamps `health`, adds `strength_stacks`
- **Resource:**
  - `Data/Debuff/blood_pact.tres` ("Blood Pact") — −20% Max HP, +1 Strength, 5 battles

### 2.4 Inventory Extension

- **`Script/Inventory/slot_data.gd`** — `quantity` setter now allows `> 1` for `DebuffData` (quantity = remaining battles).
- **`Script/Inventory/invetory_data.gd`** — added:
  - `debuff_slots: Array[SlotData]` (max 3)
  - `add_debuff(debuff, duration)` / `remove_debuff(slot_index)` / `decrement_debuff_battles()` / `get_active_debuffs()`
  - Router `add_item()` now recognises `DebuffData → debuff_slots`, `PotionData → potion_slots`, `WeaponData → weapon_slot`.
- **`Data/Stats/Player/playerInventory.tres`** — `debuff_slots` array added.

### 2.5 PlayerHandler Integration

`Script/Combat/playerHandler.gd` changes:

- `start_battle(stats)` → calls `apply_active_debuffs(stats)` before deck setup.
- Listens to `Events.combat_victory` → calls `inventory_data.decrement_debuff_battles()`.
- `use_potion(slot_index, targets)` — consumes from inventory and executes the potion's `use()`.
- `is_item_duplicate()` — fixed to compare by name for Potion and Debuff slots.

### 2.6 Room / Exploration Flow

- `Script/Exploration/room.gd` — `handle_tradeoff_room()` now picks a random item from `possible_item_pool`, prompts the player for acceptance, and routes it through `add_item()`.
- `Data/Room/spade.tres` — "Blood Exchange Room" now contains `blood_pact.tres` in its `possible_item_pool`.
- `Data/Room/heart.tres` — updated pool to include both `heal_potion.tres` and `block_potion.tres`.
- `_on_prompt_yes_confirmed()` match now includes `RoomType.Type.SPADE` alongside `DIAMOND` and `HEART` for loot routing.

### 2.7 Tests

All backend logic validated via headless Godot script:

```
/home/ganis/.gemini/antigravity/brain/463b8bb8-6ec4-4f9f-9488-9b448c0469bf/scratch/test_potion_debuff.gd
```

Run with:
```bash
HOME=/tmp godot --headless -s <path_above>
```

Last run result: **ALL TESTS PASSED** (Heal +15 HP ✅, Block +12 ✅, Debuff add ✅, apply_to_stats 60→48 HP & +1 STR ✅, 5-battle decrement & auto-expire ✅).

---

## 3 · Active State & Variables

### Autoloads (`project.godot`)

| Singleton | Script | Key State |
|---|---|---|
| `PlayerHandler` | `Script/Combat/playerHandler.gd` | Holds `inventory_data` (persistent across scenes), `character_stats` (set per combat) |
| `GameManager` | `Script/Game_System/game_manager.gd` | `current_floor`, `explored_room`, `player_hp`, `max_hp`, `active_doors_data` |
| `Events` | `Script/Game_System/eventBus.gd` | Signal bus; `combat_victory` triggers debuff decrement |
| `SceneManager` | `Scene/scene_manager.tscn` | Scene switching (`EXPLORE`, `COMBAT`, `ROOM_EVENT`) |

### Inventory Data (Runtime)

| Slot Array | Size | item_data Type | quantity Semantics |
|---|---|---|---|
| `potion_slots` | 3 | `PotionData` | Stack count (usually 1) |
| `debuff_slots` | 3 | `DebuffData` | Remaining battle count |
| `weapon_slot` | 1 | `WeaponData` | N/A (single equip) |

### Player Stats (`playerStats.tres` baseline)

`max_health=60`, `max_mana=3`, `cards_per_turn=4`. Combat duplicates this as `battle_stats`. Blood Pact reduces `max_health` to 48 and adds `strength_stacks=1`.

---

## 4 · Known Bugs & Pending Issues

### 4.1 🔴 No Potion UI in BattleUI

Backend `PlayerHandler.use_potion(slot_index)` and `InventoryData.use_potion(slot_index)` are fully functional. However, `Scene/combat.tscn` and `Script/UI/battle_ui.gd` have **no visual potion slots** — no buttons, no icons, no quantity labels. The player currently has no way to trigger potion use during combat.

### 4.2 🔴 No Debuff/Buff Status Icons in HUD

Active debuffs are stored in `debuff_slots` and their math is applied, but there is **no visible indicator** anywhere in the Battle UI or Exploration UI showing:
- Which debuffs are active
- Their remaining battle count
- Icon or tooltip

### 4.3 🟡 HP Desync: GameManager vs CharacterStats

`GameManager` maintains its own `player_hp` / `max_hp` variables independent from `CharacterStats`. After combat ends, the HP state is **not synced back** from `battle_stats` to `GameManager`. This means:
- Debuff-reduced `max_health` is not reflected in the overworld
- Post-combat health changes (damage taken, potions used) may not persist

### 4.4 🟡 Debuff Applies Every Battle (Stacking Issue)

`apply_active_debuffs()` runs `debuff.apply_to_stats(stats)` every `start_battle()` call. Since `combat.gd` does `character_stats.duplicate(true)`, the base stats are fresh each combat — so the 20% reduction is re-applied each time (which is arguably correct). However, if someone later changes combat to persist stats across battles without duplicating, the debuff would double-stack. Worth documenting as an architectural assumption.

### 4.5 🟢 Minor: `room_pool_manager.gd` TypedArray errors

During headless startup, `room_pool_manager.gd:45` logs `TypedArray` assignment errors. These are pre-existing (not introduced by this branch) and don't cause crashes, but they clutter the console.

---

## 5 · Next Steps (Priority Order)

### Step 1 — Potion UI in Combat Scene

1. Create a new script `Script/UI/potion_slot_ui.gd` — a small reusable `TextureButton` or `Panel` that displays:
   - Potion icon (`item_data.icon`)
   - Quantity badge label
   - Connects its `pressed` signal to `PlayerHandler.use_potion(index)`
2. Add an `HBoxContainer` named `PotionContainer` inside `BattleUI` (in `Scene/combat.tscn`)
3. In `battle_ui.gd`, add an `initialize_potions(inventory_data: InventoryData)` method that spawns 3 `PotionSlotUI` children
4. Connect `inventory_data.inventory_updated` → refresh all slot visuals
5. Wire this up in `combat.gd._ready()` after `battle_ui.initialize_player()`

### Step 2 — Debuff Status Bar

1. Create `Script/UI/debuff_icon_ui.gd` — shows debuff icon + remaining battles badge
2. Add a `VBoxContainer` or `HBoxContainer` in `PlayerStatsUI` area
3. Read from `PlayerHandler.inventory_data.get_active_debuffs()` and corresponding `debuff_slots[i].quantity`
4. Refresh on `inventory_updated` signal

### Step 3 — HP Sync Between GameManager and CharacterStats

1. After `combat_victory` is emitted, in `combat.gd._on_victory()`:
   - Write `battle_stats.health` → `GameManager.player_hp`
   - Write `battle_stats.max_health` → `GameManager.max_hp`
2. Consider whether `GameManager.player_hp` should be the single source of truth, or if `playerStats.tres` should persist runtime values.

### Step 4 — Additional Debuff Types

The `DebuffData` class supports `effects: Array[Effect]` for arbitrary effects. To add new debuff types:
1. Create a new `.tres` resource in `Data/Debuff/`
2. Configure its properties and attach relevant Effect sub-resources
3. Add it to a room's `possible_item_pool`

### Step 5 — Validate Headless

After each step, run:
```bash
HOME=/tmp godot --headless -s <test_script_path>
HOME=/tmp godot --headless --editor --quit   # Verify no parse errors
```

---

## 6 · Key File Map (Modified in This Branch)

| File | Lines | What Changed |
|---|---|---|
| `Script/Inventory/Item/debuff_data.gd` | 40 | **NEW** — `DebuffData` class |
| `Script/Inventory/Item/potion_data.gd` | 26 | Rewrote `use()` method with auto-targeting |
| `Script/Inventory/invetory_data.gd` | 200 | Added debuff_slots, all CRUD functions, updated router |
| `Script/Inventory/slot_data.gd` | 10 | Fixed quantity setter for DebuffData |
| `Script/Combat/playerHandler.gd` | 226 | Added debuff application, victory listener, use_potion, fixed is_item_duplicate |
| `Script/Exploration/room.gd` | 156 | Implemented `handle_tradeoff_room()`, added SPADE to confirmation router |
| `Script/Effect/health_effect.gd` | 15 | Fixed property access for node duck-typing |
| `Script/Effect/blockEffect.gd` | 16 | Fixed property access for node duck-typing |
| `Data/Debuff/blood_pact.tres` | — | **NEW** — Blood Pact debuff resource |
| `Data/Potion/heal_potion.tres` | — | Fixed: wired `healthEffect` sub-resource (amount=15) |
| `Data/Potion/block_potion.tres` | — | Fixed: wired `blockEffect` sub-resource (amount=12), fixed stale path |
| `Data/Room/spade.tres` | — | Added `blood_pact.tres` to `possible_item_pool` |
| `Data/Room/heart.tres` | — | Added both potions to `possible_item_pool` |
| `Data/Weapon/BareHand/Card/barePunch.tres` | — | Fixed stale `Script/Card/Effect/` path references |
| `Data/Stats/Player/playerInventory.tres` | — | Added `debuff_slots` array |

---

## 7 · Suggested Skills for Next Agent

- **`tdd`** — When building the Potion UI and Debuff icon bar, write tests first (extend the existing test script at the scratch path above).
- **`codebase-design`** — If refactoring the HP sync issue (GameManager vs CharacterStats single source of truth), use this skill to evaluate the module boundary.
- **`diagnosing-bugs`** — If the `room_pool_manager.gd` TypedArray errors or any runtime issues crop up during integration testing.

---

## 8 · How to Resume

```bash
cd /home/ganis/.gemini/antigravity/worktrees/SCOUNDREL-COMPFEST-18-IGI/implement_debuffs_and_potions

# Verify all tests still pass
HOME=/tmp godot --headless -s /home/ganis/.gemini/antigravity/brain/463b8bb8-6ec4-4f9f-9488-9b448c0469bf/scratch/test_potion_debuff.gd

# Verify no parse errors on project import
HOME=/tmp godot --headless --editor --quit
```

Then proceed with Step 1 (Potion UI) from Section 5.
