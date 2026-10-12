extends Node2D
class_name Powerup

@export var powerup_id: String
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.is_in_group("Player"):
		var player = body as Player
		player.apply_powerup(powerup_id)
		
		await get_tree().create_timer(3).timeout
		queue_free()
	
