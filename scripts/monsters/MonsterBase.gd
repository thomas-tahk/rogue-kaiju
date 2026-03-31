extends CharacterBody2D
class_name MonsterBase
## Base class for all playable Kaiju.
## Handles physics, damage, climbing, and attacking.
## Subclasses override _handle_input() for player/AI control.

# --- Exported base stats (set per-monster in subclass or scene) ---
@export var base_max_hp: int    = 100
@export var base_attack: int    = 20
@export var base_speed: float   = 100.0
@export var base_jump_force: float = -320.0

# --- Computed stats (base + meta upgrades applied in _ready) ---
var max_hp: int
var attack_power: int
var speed: float
var jump_force: float

# --- Runtime state ---
var current_hp: int
var is_climbing: bool = false
var facing_dir: int   = 1   # 1 = right, -1 = left

var _attack_cooldown: float = 0.0
var _is_attacking: bool     = false
const ATTACK_COOLDOWN: float = 0.35
const ATTACK_REACH: float    = 36.0   # pixels in front of monster
const GRAVITY: float          = 800.0

# --- Signals ---
signal hp_changed(current: int, maximum: int)
signal died


func _ready() -> void:
	_apply_meta_stats()
	current_hp = max_hp


func _physics_process(delta: float) -> void:
	if _attack_cooldown > 0.0:
		_attack_cooldown -= delta

	_apply_gravity(delta)
	_handle_input()
	move_and_slide()


# --- Stat application ---

func _apply_meta_stats() -> void:
	max_hp       = base_max_hp    + MetaProgression.get_upgrade_level("max_hp")    * 15
	attack_power = base_attack    + MetaProgression.get_upgrade_level("attack")    * 5
	speed        = base_speed     + MetaProgression.get_upgrade_level("speed")     * 12.0
	jump_force   = base_jump_force


# --- Physics helpers ---

func _apply_gravity(delta: float) -> void:
	if is_climbing:
		velocity.y = 0.0
		return
	if not is_on_floor():
		velocity.y += GRAVITY * delta


# --- Overridable input hook ---

func _handle_input() -> void:
	pass


# --- Public movement API (called from subclass input handlers) ---

func move_horizontal(dir: float) -> void:
	velocity.x = dir * speed
	if dir != 0.0:
		facing_dir = int(sign(dir))


func climb_vertical(dir: float) -> void:
	velocity.y = dir * speed * 0.6


func do_jump() -> void:
	if is_on_floor() or is_climbing:
		velocity.y = jump_force
		is_climbing = false


func set_climbing(value: bool) -> void:
	is_climbing = value
	if value:
		velocity.y = 0.0


# --- Attack ---

func do_attack(dir: int) -> void:
	if _attack_cooldown > 0.0 or _is_attacking:
		return
	_is_attacking     = true
	_attack_cooldown  = ATTACK_COOLDOWN
	facing_dir        = dir
	_resolve_attack_hits(dir)
	await get_tree().create_timer(0.15).timeout
	_is_attacking = false


func _resolve_attack_hits(dir: int) -> void:
	var space := get_world_2d().direct_space_state
	var params := PhysicsShapeQueryParameters2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(40.0, 36.0)
	params.shape = box
	params.transform = Transform2D(0.0, global_position + Vector2(dir * ATTACK_REACH, -20.0))
	params.collision_mask = 0xFFFFFFFF
	params.exclude = [get_rid()]

	for hit in space.intersect_shape(params, 8):
		var body = hit["collider"]
		if body is Building:
			body.take_damage(attack_power, global_position)
		elif body is EnemyBase:
			body.take_damage(attack_power)


# --- Health ---

func take_damage(amount: int) -> void:
	if current_hp <= 0:
		return
	current_hp = max(0, current_hp - amount)
	hp_changed.emit(current_hp, max_hp)
	if current_hp == 0:
		_on_died()


func heal(amount: int) -> void:
	current_hp = min(max_hp, current_hp + amount)
	hp_changed.emit(current_hp, max_hp)


func _on_died() -> void:
	died.emit()
	GameManager.game_over()
