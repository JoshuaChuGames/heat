extends Area2D
var speed = 700.0
var direction = Vector2.ZERO
var damage = 20
var despawn_cd = 5
@onready var player = get_tree().get_first_node_in_group("Player")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if player:
		direction = global_position.direction_to(player.global_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	despawn_cd -= delta
	position += direction * speed * delta
	if despawn_cd <=0:
		queue_free()




func _on_body_entered(area: Node2D) -> void:
	if area.is_in_group("Player"):
		print("hit playerd")
		if area.get_parent().has_method("do_dmg"):
				area.get_parent().do_dmg(damage)
		queue_free()
	
