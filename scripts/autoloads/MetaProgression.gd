extends Node
## Persistent cross-run progression. Saved to disk after every run.

const SAVE_PATH := "user://save_data.cfg"

var kaiju_coins: int = 0
var unlocked_monsters: Array[String] = ["george"]

# upgrade_id -> times purchased (level)
var purchased_upgrades: Dictionary = {}

# Lifetime stats (for fun/display)
var total_runs: int = 0
var total_buildings_destroyed: int = 0
var best_score: int = 0

signal meta_changed


func _ready() -> void:
	load_data()


# Called by GameManager at run end.
func end_run(results: Dictionary) -> void:
	total_runs += 1
	total_buildings_destroyed += results.get("buildings_destroyed", 0)
	var run_score: int = results.get("score", 0)
	if run_score > best_score:
		best_score = run_score
	kaiju_coins += _coins_for_run(results)
	save_data()
	meta_changed.emit()


func get_upgrade_level(upgrade_id: String) -> int:
	return purchased_upgrades.get(upgrade_id, 0)


func purchase_upgrade(upgrade_id: String, cost: int) -> bool:
	if kaiju_coins < cost:
		return false
	kaiju_coins -= cost
	purchased_upgrades[upgrade_id] = get_upgrade_level(upgrade_id) + 1
	save_data()
	meta_changed.emit()
	return true


func unlock_monster(monster_id: String) -> bool:
	if monster_id in unlocked_monsters:
		return false
	unlocked_monsters.append(monster_id)
	save_data()
	meta_changed.emit()
	return true


func save_data() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("meta",  "kaiju_coins",         kaiju_coins)
	cfg.set_value("meta",  "unlocked_monsters",   unlocked_monsters)
	cfg.set_value("meta",  "purchased_upgrades",  purchased_upgrades)
	cfg.set_value("stats", "total_runs",               total_runs)
	cfg.set_value("stats", "total_buildings_destroyed", total_buildings_destroyed)
	cfg.set_value("stats", "best_score",               best_score)
	cfg.save(SAVE_PATH)


func load_data() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	kaiju_coins        = cfg.get_value("meta",  "kaiju_coins",         0)
	unlocked_monsters  = cfg.get_value("meta",  "unlocked_monsters",   ["george"])
	purchased_upgrades = cfg.get_value("meta",  "purchased_upgrades",  {})
	total_runs               = cfg.get_value("stats", "total_runs",               0)
	total_buildings_destroyed = cfg.get_value("stats", "total_buildings_destroyed", 0)
	best_score               = cfg.get_value("stats", "best_score",               0)


func _coins_for_run(results: Dictionary) -> int:
	var coins := 0
	coins += results.get("cities_destroyed",    0) * 10
	coins += results.get("buildings_destroyed", 0) * 2
	coins += results.get("enemies_killed",      0) * 1
	return coins
