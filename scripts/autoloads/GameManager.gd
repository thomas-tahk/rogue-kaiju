extends Node
## Top-level game state machine and scene router.

enum State { MENU, PLAYING, GAME_OVER }

var state: State = State.MENU

signal state_changed(new_state: State)


func start_run() -> void:
	RunManager.begin_run()
	_set_state(State.PLAYING)
	get_tree().change_scene_to_file("res://scenes/game/GameWorld.tscn")


func go_to_main_menu() -> void:
	_set_state(State.MENU)
	get_tree().change_scene_to_file("res://scenes/main/Main.tscn")


func game_over() -> void:
	if state == State.GAME_OVER:
		return
	MetaProgression.end_run(RunManager.get_run_results())
	_set_state(State.GAME_OVER)
	# Brief delay so the monster death can visually settle
	await get_tree().create_timer(1.5).timeout
	go_to_main_menu()


func _set_state(new_state: State) -> void:
	state = new_state
	state_changed.emit(new_state)
