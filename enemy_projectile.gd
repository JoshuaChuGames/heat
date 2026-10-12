extends EnemyAttack
class_name EnemyProjectile

var speed = 200.0
var direction = Vector2.ZERO
var velocity = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		velocity = direction * speed

func _process(delta: float):
	global_position += velocity * delta

func parried(kb: float):
	process_mode = Node.PROCESS_MODE_DISABLED
	hide()

func _physics_process(delta):
	super(delta)
	if player:
		hide()
