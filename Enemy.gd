extends CharacterBody2D
class_name Enemy

#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var attack_indicator: AnimatedSprite2D = $AttackIndicator
@onready var sprite: AnimatedSprite2D = $enemy_sprite

@export var speed = 100

@export var change_direction_timer = 3
@export var move_direction = 1
@export var agro_distance = 600
@export var hp = 100
@export var damage = 10
@export var knockback = 300

var knockback_vector: Vector2

@export var damage_flash_duration: float = 0.25
@export var damage_flash_total: int = 2

signal on_death

func _init():
	set_physics_process(false)
	await ready
	set_physics_process(true)

func _ready():
	material = material.duplicate()
	pass

func show_attack_indicator() -> void:
	attack_indicator.visible = true
	attack_indicator.play("default")

func hide_attack_indicator() -> void:
	attack_indicator.visible = false

func wander_logic() -> void:	
	if move_direction < 1:
		$enemy_sprite.flip_h = true
	else:
		$enemy_sprite.flip_h = false
	velocity.x = speed * move_direction

func agro_logic() -> void:
	if player:
		if player.global_position.x < global_position.x:
			$enemy_sprite.flip_h = true
			velocity.x = speed * -1
		else:
			$enemy_sprite.flip_h = false
			velocity.x = speed
	
func idle_logic() -> void:
	velocity.x = 0
		
func take_damage(damage: int) -> void:
	hp -= damage
	if hp <= 0:
		on_death.emit()
		queue_free()
	damage_flash()

func apply_knockback(knockback: float, source_position: Vector2, kb_vector: Vector2 = Vector2.ZERO) -> void:
	if kb_vector != Vector2.ZERO:
		knockback_vector += kb_vector * knockback
	else:
		var knockback_direction = (global_position - source_position).normalized()
		knockback_vector += knockback_direction * knockback
		print(knockback_vector)

func damage_flash():
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_loops(damage_flash_total)
	tween.tween_property(material, "shader_parameter/flash_amount", 1.0, damage_flash_duration / 2)
	tween.tween_property(material, "shader_parameter/flash_amount", 0.0, damage_flash_duration / 2)
	tween.play()
