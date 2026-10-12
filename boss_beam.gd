extends EnemyAttack
class_name BossBeam

var speed = 700.0
var direction = Vector2.ZERO
var is_beaming = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	start_beam()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func start_beam():
	$Sprite2D.modulate.a = 0.0
	var tween: Tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "modulate:a", 1.0 , 1).set_ease(Tween.EASE_IN_OUT)
	$CollisionShape2D.disabled = true

	await tween.finished
	
	$CollisionShape2D.disabled = false



	
