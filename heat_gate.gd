extends StaticBody2D
class_name HeatGate

@export var heat_requirement: int = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var player = body as Player
		if player.is_dashing:
			if player.heat.current_heat >= heat_requirement:
				player.heat.current_heat -= heat_requirement
				queue_free()
