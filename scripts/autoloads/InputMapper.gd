extends Node
## Sets up all input actions programmatically.
## P1: WASD + IJKL (move + attack directions)
## P2 (future co-op): Arrow keys + numpad

func _ready() -> void:
	_setup_player_actions(0)


func _setup_player_actions(player_index: int) -> void:
	var s := "" if player_index == 0 else "_p2"

	if player_index == 0:
		_bind_key("move_left" + s,    KEY_A)
		_bind_key("move_right" + s,   KEY_D)
		_bind_key("move_up" + s,      KEY_W)
		_bind_key("move_down" + s,    KEY_S)
		_bind_key("jump" + s,         KEY_SPACE)
		_bind_key("attack_left" + s,  KEY_J)
		_bind_key("attack_right" + s, KEY_L)
		_bind_key("attack_up" + s,    KEY_I)
	else:
		_bind_key("move_left" + s,    KEY_LEFT)
		_bind_key("move_right" + s,   KEY_RIGHT)
		_bind_key("move_up" + s,      KEY_UP)
		_bind_key("move_down" + s,    KEY_DOWN)
		_bind_key("jump" + s,         KEY_KP_0)
		_bind_key("attack_left" + s,  KEY_KP_4)
		_bind_key("attack_right" + s, KEY_KP_6)
		_bind_key("attack_up" + s,    KEY_KP_8)


func _bind_key(action_name: String, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action_name, event)
