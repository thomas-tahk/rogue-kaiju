extends CharacterBody2D
class_name EnemyBase
## Base class for all military enemies.

@export var max_hp: int         = 30
@export var move_speed: float   = 55.0
@export var attack_damage: int  = 8

var current_hp: int
var target: MonsterBase = null

const GRAVITY: float = 800.0

signal died(enemy: EnemyBase)


func _ready() -> void:
	current_hp = max_hp


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	_ai_tick(delta)
	move_and_slide()


# Override in subclasses.
func _ai_tick(_delta: float) -> void:
	pass


func set_target(monster: MonsterBase) -> void:
	target = monster


func take_damage(amount: int) -> void:
	if current_hp <= 0:
		return
	current_hp -= amount
	if current_hp <= 0:
		_on_died()


func _on_died() -> void:
	RunManager.on_enemy_killed()
	died.emit(self)
	queue_free()
