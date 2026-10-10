extends Area2D
class_name EnemySlash

@export var lifetime = 0.25

var enemy: Enemy
var damage: int = 10
var knockback: float = 300
var knockback_vector: Vector2 = Vector2.ZERO

var player: Player = null

func initialize(e: Enemy, l: float = 0.25, d: int = 10, k: float = 300, kv: Vector2 = Vector2.ZERO) -> void:
	enemy = e
	lifetime = l
	damage = d
	knockback = k
	knockback_vector = kv

# Called when the node enters the scene tree for the first time.
func _ready():
	start_lifetime_timer()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_body_exited(body: Node2D):
	if body.is_in_group("Player"):
		player = body
	pass # Replace with function body.

func _on_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		player = body

func start_lifetime_timer():
	await get_tree().create_timer(lifetime).timeout
	
	queue_free()

func parried(kb: float) -> void:
	if enemy:
		var kb_vector = (enemy.global_position - global_position).normalized()
		enemy.apply_knockback(kb, global_position, kb_vector)

func _physics_process(delta):
	if player:
		for area in get_overlapping_areas():
			if area.is_in_group("ParryBox"):
				process_mode = Node.PROCESS_MODE_DISABLED
				return
		process_mode = Node.PROCESS_MODE_DISABLED
		player.take_damage(damage)
		player.apply_knockback(knockback, global_position, knockback_vector)

	
