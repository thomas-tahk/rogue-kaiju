extends Resource
class_name UpgradeData
## Defines one upgradeable slot — either a persistent meta upgrade
## or an in-run pick. Create .tres instances per upgrade.

enum Scope { META, IN_RUN }
enum StatType { HP, ATTACK, SPEED, SPECIAL }

@export var id: String            = ""
@export var display_name: String  = ""
@export var description: String   = ""
@export var scope: Scope          = Scope.IN_RUN
@export var stat_type: StatType   = StatType.HP
@export var max_level: int        = 5
@export var cost_per_level: int   = 25   # META only — kaiju_coins per purchase
@export var value_per_level: float = 10.0 # How much the stat changes per level
