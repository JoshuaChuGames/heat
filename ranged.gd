extends Enemy
class_name EnemyRanged



#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0
enum State{Patrol,Shooting,Idle}
var projectile = preload("res://projectile.tscn")
var current_state:State = State.Patrol
var shoot_cd = 2

func shoot_proj() -> void:
	if !player:
		return
	velocity.x = 0
	if shoot_cd <= 0:
		print("projectile spawn")
		var proj: EnemyProjectile = projectile.instantiate()
		proj.initialize(self, 5, damage, knockback)
		var dir_to_player = global_position.direction_to(player.global_position)
		proj.global_position = global_position + (position.direction_to(player.global_position)*100)
		proj.rotation = dir_to_player.angle() + deg_to_rad(90)
		proj.direction = dir_to_player
		get_parent().add_child(proj)
		shoot_cd = 1
		if player.global_position.x < global_position.x:
			$enemy_sprite.flip_h = false
		else:
			$enemy_sprite.flip_h = true
		sprite.play("shoot")
	
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
	if not is_on_floor() and current_state != State.Shooting :
		velocity += get_gravity() * delta
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
