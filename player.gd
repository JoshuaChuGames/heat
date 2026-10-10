extends CharacterBody2D
class_name Player

@export var heat_data: HeatGaugeData

@export var hp: int = 100
@export var max_hp: int = 100

@export var lateral_speed: int = 400
@export var fast_fall_speed: int = 200
@export var jump_speed: int = 600
@export var gravity: float = 980
@export var max_speed: float = 1000
@export var parry_max_speed: float = 50

@export var slash_delay: float = 0.25
@export var slash_duration: float = 0.15
@export var slash_heat_gain: float = 10

@export var parry_delay: float = 0.75
@export var parry_duration: float = 0.15
@export var parry_invincibility_duration: float = 0.5
@export var parry_knockback: float = 500
@export var parry_heat_gain: float = 35

@export var slash_damage: int = 10
@export var slash_knockback: float = 300


@onready var aim_object: AimObject = $AimObject

var knockback_vector: Vector2 = Vector2.ZERO

var jump_start_time: float = 0
var slash_time: float = 0
var parry_time: float = 0
var invincibility_time: float = 0
var invincibility_duration: float = 0.5

var is_jumping = false
var is_slashing = false
var is_parrying = false
var is_invincible = false

var heat: HeatGauge
var ui: PlayerUI

func _ready():
	heat = HeatGauge.new()
	
	if heat_data:
		heat.heat_data = heat_data
	
	ui = get_tree().get_first_node_in_group("PlayerUI")
	if ui:
		ui.update_hp(hp, max_hp)
		ui.update_heat(heat.current_heat, heat.total_heat)

func _process(delta):
	var current_time = Time.get_ticks_msec()
	if is_parrying && (current_time - parry_time) / 1000 > parry_delay:
		is_parrying = false
	if is_slashing && (current_time - slash_time) / 1000 > slash_delay:
		is_slashing = false
	if is_invincible && (current_time - invincibility_time) / 1000 > invincibility_duration:
		is_invincible = false
	
	pass

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	return input_direction

func calculate_velocity(delta):
	var movement_vector = get_input()
	var movement_multiplier = heat.calculate_movement_multiplier()
	movement_vector.x *= lateral_speed * movement_multiplier
	movement_vector.y = max(movement_vector.y, 0) * fast_fall_speed * movement_multiplier
	
	var new_y_velocity = velocity.y
	if !is_on_floor():
		new_y_velocity += gravity * delta
			
	elif Input.is_action_just_pressed("up"):
		is_jumping = true
		jump_start_time = Time.get_ticks_msec()
		new_y_velocity -= jump_speed
	if is_jumping:
		if Input.is_action_just_released("up"):
			print(new_y_velocity, "    ", float(jump_speed) / 2 )
		if Input.is_action_just_released("up") && abs(new_y_velocity) > float(jump_speed) / 1.5:
			new_y_velocity /= 2
	elif is_on_floor():
		is_jumping = false
		
	
	
	
	var new_velocity: Vector2 = movement_vector
	new_velocity.y += new_y_velocity
	
	if is_parrying:
		if new_velocity.x >= 0:
			new_velocity.x = min(new_velocity.x, parry_max_speed)
		else:
			new_velocity.x = min(abs(new_velocity.x), parry_max_speed) * -1
		if new_velocity.y >= 0:
			new_velocity.y = min(new_velocity.y, parry_max_speed)

	if knockback_vector.length() > 0:
		knockback_vector = knockback_vector.lerp(Vector2.ZERO, delta*20)
		new_velocity += knockback_vector
	return new_velocity
	

func _physics_process(delta):
	velocity = calculate_velocity(delta)
	move_and_slide()

func _unhandled_input(event):
	if is_parrying || is_slashing:
		return
	var current_time = Time.get_ticks_msec()
	if event.is_action_pressed("primary"):
		aim_object.slash(slash_duration)
		print(heat.calculate_movement_multiplier())
		is_slashing = true
		slash_time = current_time
		
	if event.is_action_pressed("secondary"):
		aim_object.parry(parry_duration)
		is_parrying = true
		parry_time = current_time
		


func _on_slash_area_body_entered(body):
	if body.is_in_group("Enemy"):
		body.take_damage(slash_damage)
		body.apply_knockback(slash_knockback, global_position)
		heat.increase_heat(slash_heat_gain)
		update_heat()
		return
		
func _on_parry_area_body_entered(body):
	if body.is_in_group("EnemyHitBox"):
		body.parried(parry_knockback)
		is_invincible = true
		invincibility_time = Time.get_ticks_msec()
		invincibility_duration = parry_invincibility_duration
		heat.increase_heat(parry_heat_gain)
		update_heat()
		return
		
func take_damage(damage: int) -> void:
	if is_invincible:
		return
	hp -= damage
	update_hp()
	if hp <= 0:
		queue_free()

func apply_knockback(knockback: float, source_position: Vector2, kb_vector: Vector2 = Vector2.ZERO) -> void:
	if kb_vector != Vector2.ZERO:
		knockback_vector += kb_vector * knockback
	else:
		var knockback_direction = (global_position - source_position).normalized()
		knockback_vector += knockback_direction * knockback

func update_heat():
	ui.update_heat(heat.current_heat, heat.total_heat)

func update_hp() -> void:
	ui.update_hp(hp, max_hp)
