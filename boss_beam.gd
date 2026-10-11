extends Area2D
var speed = 700.0
var direction = Vector2.ZERO
var damage = 40
var is_beaming = false
@onready var player = get_tree().get_first_node_in_group("Player")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.modulate.a = 0.2
	await get_tree().create_timer(0.2).timeout
		
	$Sprite2D.modulate.a = 0.6
	await get_tree().create_timer(0.2).timeout
	$Sprite2D.modulate.a = 1.0
	await get_tree().create_timer(0.5).timeout
	var hits = get_overlapping_bodies()
	for hit in hits:
		if hit.is_in_group("Player"):
			print("hitplaeyrrrrrrrrrrrrr")
			if hit.has_method("take_dmg"):
				hit.take_dmg(damage) 
				
				# call player take dmg function
	
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass





	
