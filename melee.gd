extends Enemy
class_name EnemyMelee


#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0
var enemy_slash = preload("res://enemy_slash.tscn")

enum State{Idle,Patrol,Attacking, Agro, Lunging}


var current_state:State = State.Patrol
@export var lunge_speed = 600
@export var lunge_distance = 400
@export var lunge_cooldown = 3
@export var lunge_duration = 1

@export var lunge_timer = 0
@export var lunge_vector: Vector2 = Vector2.ZERO
@export var swing_cooldown = 2
@export var swing_delay = 0.25
@export var attack_distance = 200


func _init():
	set_physics_process(false)
	await ready
	set_physics_process(true)

func _ready():
	material = material.duplicate()
	pass

func start_lunge()->void:
	current_state = State.Lunging
	lunge_timer = lunge_duration
	lunge_cooldown = 3
	if player:
		lunge_vector = (player.global_position - global_position).normalized()

func lunge_logic() -> void:
	velocity.x = lunge_vector.x * lunge_speed
		
			
func enemy_slash_action() -> void:
	if !player:
		return
	var dist_to_player = global_position.distance_to(player.global_position)
	if swing_cooldown <= 0 and swing_delay <= 0:
		var slash: EnemySlash = enemy_slash.instantiate()
		var dir_to_player = global_position.direction_to(player.global_position)
		if dist_to_player > attack_distance:
			slash.global_position = global_position + (position.direction_to(player.global_position)*attack_distance)
		else:
			slash.global_position = player.global_position
		slash.rotation = dir_to_player.angle() + deg_to_rad(90)
		slash.initialize(self, 0.25, damage, knockback, dir_to_player)
		get_parent().add_child(slash)
		swing_cooldown = 2
		swing_delay = 0.25
		current_state = State.Patrol
		if player.global_position.x < global_position.x:
			$enemy_sprite.flip_h = false
		else:
			$enemy_sprite.flip_h = true
		sprite.play("lunge")
	
func update_State()-> void:
	if not player:
		return
	var dist_to_player = global_position.distance_to(player.global_position)
	
	match current_state:
		State.Patrol:
			if (dist_to_player < lunge_distance and lunge_cooldown <=0): # if player within enemy radius, placeholder 
				start_lunge()
			elif dist_to_player < agro_distance:
				current_state = State.Agro
			if change_direction_timer <= 0:
				current_state = State.Idle
				change_direction_timer = 2.5
		State.Agro:
			if (dist_to_player < lunge_distance and lunge_cooldown <=0): # if player within enemy radius, placeholder 
				start_lunge()
			elif dist_to_player > agro_distance:
				current_state = State.Patrol
		State.Idle:
			if dist_to_player < lunge_distance and lunge_cooldown <=0 :
				start_lunge()
			elif dist_to_player < agro_distance:
				current_state = State.Agro
			elif change_direction_timer <= 0:
				current_state = State.Patrol
				move_direction *= -1
				change_direction_timer = 3
		State.Lunging:
			if dist_to_player <= attack_distance:
				current_state = State.Attacking
				show_attack_indicator()
				swing_delay = 0.25
				swing_cooldown = 0
				lunge_cooldown = 3
			elif lunge_timer <= 0:
				current_state = State.Attacking
				show_attack_indicator()
				swing_delay = 0.25
				swing_cooldown = 0
				lunge_cooldown = 3
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
	if current_state == State.Agro:
		print("agro")
		agro_logic()
	if current_state == State.Idle:
		print("idle")
		idle_logic()
	if(current_state == State.Attacking):
		print("attackingd")
		enemy_slash_action()
		velocity.x = 0
	if knockback_vector.length() > 0:
		knockback_vector = knockback_vector.lerp(Vector2.ZERO, delta*20)
		velocity += knockback_vector
	
	if velocity.x != 0 && knockback_vector.length() <= 0:
		if velocity.x < 0:
			$enemy_sprite.flip_h = false
		else:
			$enemy_sprite.flip_h = true
		
		sprite.play("run")
	else:
		sprite.play("idle")
	
	move_and_slide()
