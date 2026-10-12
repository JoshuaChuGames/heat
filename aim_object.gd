extends Node2D
class_name AimObject

@onready var slash_sprite: AnimatedSprite2D = $SlashSprite
@onready var slash_area: Area2D = $SlashArea
@onready var parry_sprite: AnimatedSprite2D = $ParrySprite
@onready var parry_area: Area2D = $ParryArea
@onready var aim_indicator_sprite: Sprite2D = $AimIndicatorSprite

@export var aim_indicator_distance: int = 300
@export var slash_distance: int = 500
@export var parry_distance: int = 500

enum AimQuadrant {
	UPLEFT,
	UPRIGHT,
	DOWNLEFT,
	DOWNRIGHT,
	FORWARDLEFT,
	FORWARDRIGHT,
}
var aim_vector: Vector2 = Vector2.ZERO

func show_slash():
	slash_sprite.position = aim_indicator_sprite.position.normalized() * slash_distance
	slash_sprite.rotation = aim_indicator_sprite.rotation
	slash_sprite.show()
	slash_sprite.play("slash")

func hide_slash():
	slash_sprite.hide()
	slash_sprite.stop()

func show_parry():
	parry_sprite.position = aim_indicator_sprite.position.normalized() * parry_distance
	parry_sprite.rotation = aim_indicator_sprite.rotation
	parry_sprite.show()
	parry_sprite.play("parry")

func hide_parry():
	parry_sprite.hide()
	parry_sprite.stop()

func enable_slash_area(slash_duration: float):
	slash_area.process_mode = Node.PROCESS_MODE_INHERIT
	
	slash_area.rotation = aim_indicator_sprite.rotation
	
	await get_tree().create_timer(slash_duration).timeout
	
	slash_area.process_mode = Node.PROCESS_MODE_DISABLED
	
	
func enable_parry_area(parry_duration: float):
	parry_area.process_mode = Node.PROCESS_MODE_INHERIT
	
	parry_area.rotation = aim_indicator_sprite.rotation
	
	await get_tree().create_timer(parry_duration).timeout
	
	parry_area.process_mode = Node.PROCESS_MODE_DISABLED

func _process(delta):
	var mouse_position: Vector2 = get_global_mouse_position()
	aim_vector = (mouse_position - global_position).normalized()
	var aim_angle = (mouse_position - global_position).angle() + PI/2
	
	aim_indicator_sprite.position = (mouse_position - global_position).normalized() * aim_indicator_distance
	aim_indicator_sprite.rotation = aim_angle
	print(AimQuadrant.keys()[get_aim_quadrant()])

func slash(slash_duration: float):
	show_slash()
	enable_slash_area(slash_duration)
	slash_area.rotation = aim_indicator_sprite.rotation

func parry(parry_duration: float):
	show_parry()
	enable_parry_area(parry_duration)
	parry_area.rotation = aim_indicator_sprite.rotation
	
	
func get_aim_quadrant():
	var angle = aim_vector.angle()
	if angle >= -PI/6 and angle < PI/6:
		return AimQuadrant.FORWARDRIGHT
	elif angle >= PI/6 and angle < PI/2:
		return AimQuadrant.DOWNRIGHT
	elif angle >= PI/2 and angle < 5*PI/6:
		return AimQuadrant.DOWNLEFT
	elif angle >= 5*PI/6 or angle < -5*PI/6:
		return AimQuadrant.FORWARDLEFT
	elif angle >= -5*PI/6 and angle < -PI/2:
		return AimQuadrant.UPLEFT
	else:
		return AimQuadrant.UPRIGHT
