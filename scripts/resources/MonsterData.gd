extends Resource
class_name MonsterData
## Static definition for a monster type. Create .tres instances for each monster.

@export var id: String                     = ""
@export var display_name: String           = ""
@export var description: String            = ""
@export var base_max_hp: int               = 100
@export var base_attack: int               = 20
@export var base_speed: float              = 100.0
@export var scene_path: String             = ""
@export var unlocked_by_default: bool      = false
@export var unlock_cost: int               = 50   # in kaiju_coins
