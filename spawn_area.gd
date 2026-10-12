extends Area2D
class_name SpawnArea

@export var spawn_entity: PackedScene
@export var spawn_count: int = 1
@export var spawn_delay: float = 1.0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if spawn_entity == null:
		print("No spawn entity assigned to SpawnArea")
		return
	if body.is_in_group("Player"):
		while spawn_count > 0:
			spawn_count -= 1
			await get_tree().create_timer(spawn_delay).timeout
			var entity = spawn_entity.instantiate()
			entity.global_position = global_position
			entity.global_position.y -= 250
			get_parent().add_child(entity)
		
