extends StaticBody2D
class_name Building
## A destroyable building. Dimensions are set via exports and applied in _ready.
## Damage state drives the visual tint until real sprites are added.

@export var building_width: int  = 64
@export var building_height: int = 128
@export var max_hp: int          = 180

var current_hp: int
var is_destroyed: bool = false

enum DamageState { HEALTHY, DAMAGED, CRITICAL, DESTROYED }
var _damage_state: DamageState = DamageState.HEALTHY

signal building_destroyed(building: Building)

@onready var _sprite:    ColorRect         = $Sprite
@onready var _collision: CollisionShape2D  = $CollisionShape2D


func _ready() -> void:
	current_hp = max_hp
	_configure_shapes()


func _configure_shapes() -> void:
	var shape := RectangleShape2D.new()
	shape.size = Vector2(building_width, building_height)
	_collision.shape    = shape
	_collision.position = Vector2(0.0, -building_height * 0.5)

	_sprite.size     = Vector2(building_width, building_height)
	_sprite.position = Vector2(-building_width * 0.5, -building_height)


func take_damage(amount: int, _hit_pos: Vector2 = Vector2.ZERO) -> void:
	if is_destroyed:
		return
	current_hp -= amount
	_refresh_damage_state()

	if current_hp <= 0:
		_collapse()


func _refresh_damage_state() -> void:
	var ratio := float(current_hp) / float(max_hp)
	var new_state: DamageState

	if   ratio > 0.60: new_state = DamageState.HEALTHY
	elif ratio > 0.30: new_state = DamageState.DAMAGED
	elif ratio > 0.0:  new_state = DamageState.CRITICAL
	else:              new_state = DamageState.DESTROYED

	if new_state != _damage_state:
		_damage_state = new_state
		_update_tint()


func _update_tint() -> void:
	match _damage_state:
		DamageState.HEALTHY:   _sprite.color = Color(0.40, 0.45, 0.52)
		DamageState.DAMAGED:   _sprite.color = Color(0.55, 0.42, 0.28)
		DamageState.CRITICAL:  _sprite.color = Color(0.60, 0.30, 0.20)
		DamageState.DESTROYED: _sprite.color = Color(0.25, 0.22, 0.18)


func _collapse() -> void:
	is_destroyed = true
	_collision.set_deferred("disabled", true)
	_update_tint()
	RunManager.on_building_destroyed()
	building_destroyed.emit(self)

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	tween.tween_callback(queue_free)
