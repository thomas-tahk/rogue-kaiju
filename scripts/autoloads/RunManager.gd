extends Node
## Tracks all mutable state for the current run.
## Resets completely on begin_run(). Does not persist between runs.

var selected_monster_id: String = "george"
var current_city_index: int = 0
var cities_destroyed: int = 0
var buildings_destroyed: int = 0
var enemies_killed: int = 0
var score: int = 0

# In-run upgrades chosen at city transitions
var active_upgrades: Array[String] = []

signal score_changed(new_score: int)
signal city_completed(city_index: int)


func begin_run() -> void:
	current_city_index = 0
	cities_destroyed = 0
	buildings_destroyed = 0
	enemies_killed = 0
	score = 0
	active_upgrades.clear()


func on_building_destroyed() -> void:
	buildings_destroyed += 1
	_add_score(100)


func on_enemy_killed() -> void:
	enemies_killed += 1
	_add_score(25)


func on_city_completed() -> void:
	cities_destroyed += 1
	city_completed.emit(current_city_index)
	current_city_index += 1


func add_in_run_upgrade(upgrade_id: String) -> void:
	active_upgrades.append(upgrade_id)


func has_upgrade(upgrade_id: String) -> bool:
	return upgrade_id in active_upgrades


func get_run_results() -> Dictionary:
	return {
		"monster_id":          selected_monster_id,
		"cities_destroyed":    cities_destroyed,
		"buildings_destroyed": buildings_destroyed,
		"enemies_killed":      enemies_killed,
		"score":               score,
	}


func _add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)
