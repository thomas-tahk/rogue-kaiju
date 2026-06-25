extends Node2D
## Root of the gameplay scene. Spawns the city and player, runs the HUD.

const PLAYER_MONSTER_SCENE := preload("res://scenes/monsters/PlayerMonster.tscn")
const BUILDING_SCENE        := preload("res://scenes/buildings/Building.tscn")

# City layout constants
const GROUND_Y: float        = 180.0
const BUILDING_SPACING: float = 16.0
const BUILDING_START_X: float = 80.0

# Randomised building sizes
const MIN_WIDTH: int  = 48
const MAX_WIDTH: int  = 80
const MIN_HEIGHT: int = 80
const MAX_HEIGHT: int = 160
const BUILDINGS_PER_CITY: int = 10

# Enemy spawning
const SOLDIER_SCENE := preload("res://scenes/enemies/Soldier.tscn")
const ENEMY_SPAWN_INTERVAL: float = 6.0

var _player: PlayerMonster
var _buildings_remaining: int = 0
var _enemy_spawn_timer: float = ENEMY_SPAWN_INTERVAL

@onready var _camera:            Camera2D    = $Camera2D
@onready var _building_root:     Node2D      = $BuildingRoot
@onready var _enemy_root:        Node2D      = $EnemyRoot
@onready var _hud:               CanvasLayer = $HUD
@onready var _hud_score:         Label       = $HUD/ScoreLabel
@onready var _hud_hp:            Label       = $HUD/HPLabel
@onready var _hud_city:          Label       = $HUD/CityLabel


func _ready() -> void:
	_spawn_backdrop()
	_spawn_city()
	_spawn_player()
	_update_hud_city()
	RunManager.score_changed.connect(_on_score_changed)


# --- Backdrop ---
# Dusk sky gradient plus a tiled distant-city silhouette, both on negative
# CanvasLayers so they sit behind the gameplay and don't scroll with it.
# (Skyline vertical offset can be nudged in-editor to taste.)
func _spawn_backdrop() -> void:
	var sky_layer := CanvasLayer.new()
	sky_layer.layer = -10
	var sky := TextureRect.new()
	sky.texture = preload("res://assets/env/sky.png")
	sky.stretch_mode = TextureRect.STRETCH_SCALE
	sky.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sky_layer.add_child(sky)
	add_child(sky_layer)

	var skyline_layer := CanvasLayer.new()
	skyline_layer.layer = -9
	var skyline := TextureRect.new()
	skyline.texture = preload("res://assets/env/skyline.png")
	skyline.stretch_mode = TextureRect.STRETCH_TILE
	skyline.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	skyline.anchor_left = 0.0
	skyline.anchor_right = 1.0
	skyline.anchor_top = 1.0
	skyline.anchor_bottom = 1.0
	skyline.offset_top = -136.0   # 96px-tall silhouette, lifted off the bottom
	skyline.offset_bottom = -40.0
	skyline_layer.add_child(skyline)
	add_child(skyline_layer)


func _process(delta: float) -> void:
	_follow_camera()
	_tick_enemy_spawner(delta)


# --- City generation ---

func _spawn_city() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var cursor_x := BUILDING_START_X

	for i in range(BUILDINGS_PER_CITY):
		var w: int = rng.randi_range(MIN_WIDTH, MAX_WIDTH)
		var h: int = rng.randi_range(MIN_HEIGHT, MAX_HEIGHT)

		var b: Building = BUILDING_SCENE.instantiate()
		b.building_width  = w
		b.building_height = h
		b.max_hp          = h * 2   # Taller buildings are tougher
		b.position        = Vector2(cursor_x + w * 0.5, GROUND_Y)
		b.building_destroyed.connect(_on_building_destroyed)
		_building_root.add_child(b)

		cursor_x += w + BUILDING_SPACING

	_buildings_remaining = BUILDINGS_PER_CITY
	_spawn_ground(cursor_x + 200.0)


func _spawn_ground(width: float) -> void:
	var ground := StaticBody2D.new()
	var col    := CollisionShape2D.new()
	var shape  := RectangleShape2D.new()
	shape.size = Vector2(width + 400.0, 24.0)
	col.shape    = shape
	col.position = Vector2(width * 0.5, GROUND_Y + 12.0)
	ground.add_child(col)

	var visual := TextureRect.new()
	visual.texture       = preload("res://assets/env/ground.png")
	visual.stretch_mode  = TextureRect.STRETCH_TILE
	visual.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	visual.size          = Vector2(width + 400.0, 28.0)
	visual.position      = Vector2(-200.0, GROUND_Y)
	add_child(visual)

	add_child(ground)


# --- Player ---

func _spawn_player() -> void:
	_player = PLAYER_MONSTER_SCENE.instantiate()
	_player.position = Vector2(30.0, GROUND_Y - 2.0)
	add_child(_player)
	_player.died.connect(_on_player_died)
	_player.hp_changed.connect(_on_hp_changed)
	_on_hp_changed(_player.max_hp, _player.max_hp)


# --- Camera ---

func _follow_camera() -> void:
	if not is_instance_valid(_player):
		return
	_camera.position.x = lerp(_camera.position.x, _player.global_position.x, 0.12)
	_camera.position.y = lerp(_camera.position.y, _player.global_position.y - 60.0, 0.10)


# --- Enemy spawning ---

func _tick_enemy_spawner(delta: float) -> void:
	_enemy_spawn_timer -= delta
	if _enemy_spawn_timer > 0.0:
		return
	_enemy_spawn_timer = ENEMY_SPAWN_INTERVAL
	_spawn_soldier()


func _spawn_soldier() -> void:
	if not is_instance_valid(_player):
		return
	var soldier: Soldier = SOLDIER_SCENE.instantiate()
	# Spawn off-screen in a random direction
	var side := 1 if randf() > 0.5 else -1
	soldier.position = Vector2(_player.global_position.x + side * 280.0, GROUND_Y - 10.0)
	soldier.set_target(_player)
	_enemy_root.add_child(soldier)


# --- HUD ---

func _update_hud_city() -> void:
	_hud_city.text = "City %d" % (RunManager.current_city_index + 1)


func _on_score_changed(new_score: int) -> void:
	_hud_score.text = "Score: %d" % new_score


func _on_hp_changed(current: int, maximum: int) -> void:
	_hud_hp.text = "HP: %d / %d" % [current, maximum]


# --- Events ---

func _on_building_destroyed(_building: Building) -> void:
	_buildings_remaining -= 1
	if _buildings_remaining <= 0:
		_city_cleared()


func _city_cleared() -> void:
	RunManager.on_city_completed()
	# TODO: show in-run upgrade selection before loading next city
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()


func _on_player_died() -> void:
	pass  # GameManager.game_over() is called inside MonsterBase._on_died()
