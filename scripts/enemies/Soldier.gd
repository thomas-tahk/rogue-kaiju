extends EnemyBase
class_name Soldier
## Basic ground unit. Walks toward the monster, stops to shoot at range.

@export var shoot_range: float   = 180.0
@export var shoot_interval: float = 2.2

var _shoot_timer: float = 0.0


func _ai_tick(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		return

	_shoot_timer -= delta
	var dist := global_position.distance_to(target.global_position)

	if dist > shoot_range:
		# Walk toward monster
		var dir := sign(target.global_position.x - global_position.x)
		velocity.x = dir * move_speed
	else:
		velocity.x = 0.0
		if _shoot_timer <= 0.0:
			_shoot()


func _shoot() -> void:
	_shoot_timer = shoot_interval
	if target and is_instance_valid(target):
		target.take_damage(attack_damage)
		# TODO: spawn a visible bullet projectile
