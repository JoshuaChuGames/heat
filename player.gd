extends CharacterBody2D
class_name Player

@export var heat_data: HeatGaugeData

@export var lateral_speed: int = 400
@export var fast_fall_speed: int = 200
@export var jump_speed: int = 600
@export var gravity: float = 980
@export var max_speed: float = 1000
@export var parry_max_speed: float = 50

@export var slash_delay: float = 0.25
@export var slash_duration: float = 0.15

@export var parry_delay: float = 0.75
@export var parry_duration: float = 0.15


@onready var aim_object: AimObject = $AimObject

var jump_start_time: float = 0
var slash_time: float = 0
var parry_time: float = 0

var is_jumping = false
var is_slashing = false
var is_parrying = false

var heat: HeatGauge

func _ready():
	heat = HeatGauge.new()
	
	if heat_data:
		heat.heat_data = heat_data
	pass 	

func _process(delta):
	var current_time = Time.get_ticks_msec()
	if is_parrying && (current_time - parry_time) / 1000 > parry_delay:
		is_parrying = false
	if is_slashing && (current_time - slash_time) / 1000 > slash_delay:
		is_slashing = false
	
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
		
		heat.movement_speed += 10
		print(heat.calculate_movement_multiplier())
		is_slashing = true
		slash_time = current_time
		
	if event.is_action_pressed("secondary"):
		aim_object.parry(parry_duration)
		is_parrying = true
		parry_time = current_time
		
