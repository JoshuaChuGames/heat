extends CharacterBody2D


#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0
@onready var player = get_tree().get_first_node_in_group("Player")
enum State{Patrol,Shooting,Idle}
var projectile = preload("res://projectile.tscn")
var current_state:State = State.Patrol
var speed = 150
var change_direction_timer = 3
var move_direction = 1
var hp = 100
var shoot_cd = 2

func despawn() -> void:
	queue_free()
func take_damage(damage) -> void:
	if hp > 0:
		hp -= damage
		if hp <= 0:
			despawn()

func shoot_proj() -> void:
	velocity.x = 0
	if shoot_cd <= 0:
		print("projectile spawn")
		var proj = projectile.instantiate()
		var dir_to_player = global_position.direction_to(player.global_position)
		proj.global_position = global_position + (position.direction_to(player.global_position)*100)
		proj.rotation = dir_to_player.angle() + deg_to_rad(90)
		get_parent().add_child(proj)
		shoot_cd = 1
	
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
				if change_direction_timer <= 0:
					current_state = State.Idle
					change_direction_timer = 2.5
			if dist_to_player < 500:
				current_state = State.Shooting
				shoot_cd = 2
				velocity.x = 0
		State.Idle:
			if change_direction_timer <= 0:
				current_state = State.Patrol
				move_direction *= -1
				change_direction_timer = 3
			if dist_to_player < 500:
				current_state = State.Shooting
				shoot_cd = 2
				velocity.x = 0
		State.Shooting:
			if dist_to_player > 500:
				current_state = State.Patrol
				change_direction_timer = 3
				velocity.x = speed
		
	
	
func _physics_process(delta: float) -> void:
	change_direction_timer -= delta
	shoot_cd -= delta
	update_State()
	if current_state == State.Patrol:
		wander_logic()
	if current_state == State.Idle:
		idle_logic()
		velocity.x = 0
	if current_state == State.Shooting:
		shoot_proj()
	move_and_slide()
