extends CharacterBody2D
class_name Player

@export var lateral_speed: int = 400
@export var fast_fall_speed: int = 200
@export var jump_speed: int = 600
@export var gravity: float = 980
@export var max_speed: float = 1000

@export var full_hop_input_duration: int = 0.25
@export var full_hop_duration: int = 0.5

var jump_start_time: float = 0
var is_jumping = true
var is_full_hopping = true

func _ready():
	pass 	

func _process(delta):
	pass

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	return input_direction

func calculate_velocity(delta):
	var movement_vector = get_input()
	movement_vector.x *= lateral_speed
	movement_vector.y = max(movement_vector.y, 0) * fast_fall_speed
	
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
	
	return new_velocity
	

func _physics_process(delta):
	velocity = calculate_velocity(delta)
	move_and_slide()
