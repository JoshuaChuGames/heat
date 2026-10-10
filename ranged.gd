extends CharacterBody2D

#var player = get_tree().get_first_node_in_group("Player")
#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0

enum State{Patrol,Attacking}
var projectile = preload("res://projectile.tscn")
var current_state:State = State.Patrol
var speed = 150
var change_direction_timer = 3
var move_direction = 1
var hp = 100
var timer_reached = false

var reset_timer = 3

func attack_logic() -> void:
	var proj = projectile.instantiate()
	proj.global_position = proj.global_position
	#proj.direction = (player.global_position - global_position)
	#proj.rotation = proj.direction.angle()
	
	
func wander_logic() -> void:	
	var bounced = false
	print(change_direction_timer)
	print(move_direction)
	
	if change_direction_timer <= 0:
		#wait 3 seconds, then reset timer and go in the other direction
		bounced = true	
	if bounced:
		velocity.x = 0
		move_direction *= -1
		#await get_tree().create_timer(2.5).timeout
		change_direction_timer = 3
		
		
	
	
	velocity.x = speed * move_direction
	move_and_slide()
	
	
func update_State()-> void:
	match current_state:
		State.Patrol:
			if (global_position.distance_to(player.global_position) < 50): # if player within enemy radius, placeholder 
				State.Attacking
		State.Attacking:
			if true and reset_timer ==0:
				State.Patrol
		
	
	
	
func _physics_process(delta: float) -> void:
	change_direction_timer -= delta
	wander_logic()
	if State.Attacking:
		attack_logic()
	if State.Patrol:
		wander_logic()
		
	
