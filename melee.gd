extends CharacterBody2D


#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0
var enemy_slash = preload("res://enemy_slash.tscn")

@onready var player = get_tree().get_first_node_in_group("Player")


enum State{Idle,Patrol,Attacking,Lunging}


var current_state:State = State.Patrol
var speed = 100
var lunge_speed = 500
var lunge_distance = 400
var lunge_cooldown = 3
var lunge_duration = 1
var lunge_timer = 0
var change_direction_timer = 3
var move_direction = 1
var hp = 100

var timer_reached = false

var swing_cooldown = 2
var swing_delay = 0.5
var attack_distance = 200

func start_lunge()->void:
	current_state = State.Lunging
	lunge_timer = lunge_duration
	lunge_cooldown = 3
func lunge_logic() -> void:
	if player:
		if player.global_position.x < global_position.x:
			$enemy_sprite.flip_h = true
		else:
			$enemy_sprite.flip_h = false
		var lunge_direction = global_position.direction_to(player.global_position)
		velocity = lunge_speed * lunge_direction
		
			
func enemy_slash_action() -> void:
	if swing_cooldown <= 0 and swing_delay <= 0:
		var slash = enemy_slash.instantiate()
		var dir_to_player = global_position.direction_to(player.global_position)
		slash.global_position = player.global_position
		slash.rotation = dir_to_player.angle() + deg_to_rad(90)
		get_parent().add_child(slash)
		swing_cooldown = 2
		swing_delay = 0.5


	pass
func wander_logic() -> void:	
	if move_direction < 1:
		$enemy_sprite.flip_h = true
	else:
		$enemy_sprite.flip_h = false
	velocity.x = speed * move_direction
	
func idle_logic() -> void:
	velocity.x = 0
	
func update_State()-> void:
	if not player:
		return
	var dist_to_player = global_position.distance_to(player.global_position)
	
	match current_state:
		State.Patrol:
			if player:
				if (dist_to_player < lunge_distance and lunge_cooldown <=0): # if player within enemy radius, placeholder 
					start_lunge()
				if change_direction_timer <= 0:
					current_state = State.Idle
					change_direction_timer = 2.5
		State.Attacking:
			if (dist_to_player > lunge_distance):
				current_state = State.Patrol
				lunge_cooldown = 3
				change_direction_timer = 3
			elif dist_to_player > attack_distance:
				if lunge_cooldown <= 0:
					start_lunge()
				else: 
					current_state = State.Patrol
			
				
		State.Idle:
			if dist_to_player < lunge_distance and lunge_cooldown <=0 :
				start_lunge()
			elif change_direction_timer <= 0:
				current_state = State.Patrol
				move_direction *= -1
				change_direction_timer = 3
		State.Lunging:
			if dist_to_player <= attack_distance:
				current_state = State.Attacking
				swing_delay = 0.5
				swing_cooldown = 0
				lunge_cooldown = 3
			elif lunge_timer <= 0 or dist_to_player > lunge_distance:
				current_state = State.Patrol
				change_direction_timer = 3
func _physics_process(delta: float) -> void:
	if not is_on_floor() and current_state != State.Lunging :
		velocity += get_gravity() * delta
	change_direction_timer -= delta
	lunge_cooldown -= delta
	swing_delay -= delta
	swing_cooldown -= delta
	lunge_timer -= delta
	update_State()
	if current_state == State.Lunging:
		print("lunging")
		lunge_logic()
	if current_state == State.Patrol:
		print("patrol")
		wander_logic()
	if current_state == State.Idle:
		print("idle")
		idle_logic()
	if(current_state == State.Attacking):
		print("attackingd")
		enemy_slash_action()
		velocity.x = 0
	move_and_slide()
		
	
