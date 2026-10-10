extends CharacterBody2D


#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0
#var enemy_slash = preload()

#var player = get_tree().get_first_node_in_group("Player")


enum State{Patrol,Attacking}


var current_state:State = State.Patrol
var speed = 150
var change_direction_timer = 3
var move_direction = 1
var hp = 100
var timer_reached = false
var attack_cooldown = 3

func attack_logic() -> void:
	#change logic so it lunges at the player then makes a slash object 
	
	#var slash = enemy_slash.instantiate()
	#slash.global_position = slash.global_position
	#slash.direction = (player.global_position - global_position)
	#slash.rotation = slash.direction.angle()
	pass
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
	#match current_state:
		#State.Patrol:
			#if (global_position.distance_to(player.global_position) < 50): # if player within enemy radius, placeholder 
				#State.Attacking
		#State.Attacking:
			#if false:
				#State.Patrol
	pass
		
	
	
	
func _physics_process(delta: float) -> void:
	change_direction_timer -= delta
	wander_logic()
	if State.Attacking:
		attack_logic()
	if State.Patrol:
		wander_logic()
		
	
