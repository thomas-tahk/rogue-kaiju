extends MonsterBase
class_name PlayerMonster
## Player-controlled monster. Reads keyboard input for player_index.
## player_index 0 = P1 (WASD + IJKL), 1 = P2 (arrows + numpad).

@export var player_index: int = 0

# Wall-grab rays (assigned in scene)
@onready var _ray_left:  RayCast2D = $WallRayLeft
@onready var _ray_right: RayCast2D = $WallRayRight


func _handle_input() -> void:
	var s := _suffix()

	# Horizontal movement
	var h := Input.get_axis(_a("move_left", s), _a("move_right", s))
	move_horizontal(h)
	$Body.flip_h = facing_dir < 0   # sprite faces right by default

	if is_climbing:
		# Vertical climbing
		var v := Input.get_axis(_a("move_up", s), _a("move_down", s))
		climb_vertical(v)
		# Let go of wall
		if Input.is_action_just_pressed(_a("jump", s)):
			set_climbing(false)
			do_jump()
	else:
		if Input.is_action_just_pressed(_a("jump", s)):
			# Try to grab wall first, otherwise jump
			if _can_grab_wall():
				set_climbing(true)
			else:
				do_jump()

	# Attacks
	if Input.is_action_just_pressed(_a("attack_left", s)):
		do_attack(-1)
	elif Input.is_action_just_pressed(_a("attack_right", s)):
		do_attack(1)
	elif Input.is_action_just_pressed(_a("attack_up", s)):
		_do_upward_attack()


func _can_grab_wall() -> bool:
	return _ray_left.is_colliding() or _ray_right.is_colliding()


func _do_upward_attack() -> void:
	# Upward punch: hits things directly above (helicopters, windows, etc.)
	if _attack_cooldown > 0.0 or _is_attacking:
		return
	_is_attacking    = true
	_attack_cooldown = ATTACK_COOLDOWN
	_resolve_upward_hits()
	await get_tree().create_timer(0.15).timeout
	_is_attacking = false


func _resolve_upward_hits() -> void:
	var space := get_world_2d().direct_space_state
	var params := PhysicsShapeQueryParameters2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(28.0, 36.0)
	params.shape = box
	params.transform = Transform2D(0.0, global_position + Vector2(0.0, -52.0))
	params.collision_mask = 0xFFFFFFFF
	params.exclude = [get_rid()]

	for hit in space.intersect_shape(params, 8):
		var body = hit["collider"]
		if body is Building:
			body.take_damage(attack_power, global_position)
		elif body is EnemyBase:
			body.take_damage(attack_power)


# --- Helpers ---

func _suffix() -> String:
	return "" if player_index == 0 else "_p2"


func _a(action: String, suffix: String) -> String:
	return action + suffix
