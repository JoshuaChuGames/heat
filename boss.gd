extends Enemy
class_name EnemyBoss

var projectile = preload("res://projectile.tscn")
var beam = preload("res://boss_beam.tscn")
var current_state:State = State.Idle
var enemy_slash = preload("res://enemy_slash.tscn")
var idle_timer = 2
var melee_timer = 2
var shoot_cd = 1
var swing_delay = 0.3
var has_swung = false
var shots_fired = 0
var is_attacking = false
var barrage_finished = false
var ranged_finished = false
enum State{Melee,Ranged,Barrage,Idle}

func boss_melee() -> void:
	if !player:
		return
	var dist_to_player = global_position.distance_to(player.global_position)
	var move_direction = 1
	if player.global_position.x > global_position.x:
		move_direction = 1
	else:
		move_direction = -1
	if dist_to_player > 300:
		velocity.x = speed * move_direction
		if swing_delay <= 0: # so it doesn't cancel midswing
			swing_delay = 0.5
		
	else:
		velocity.x = 0
	if dist_to_player <= 300 and !has_swung:
		if swing_delay <=0:
			var slash: EnemySlash = enemy_slash.instantiate()
			var dir_to_player = global_position.direction_to(player.global_position)
			slash.initialize(self, 0.25, damage, knockback, dir_to_player)
			slash.global_position = player.global_position
			slash.rotation = dir_to_player.angle() + deg_to_rad(90)
			get_parent().add_child(slash)
			
			#make melee object/slash
			has_swung = true
			print("swung")
			if player.global_position.x < global_position.x:
				$enemy_sprite.flip_h = true
			else:
				$enemy_sprite.flip_h = false

func ranged_attack() -> void:
	if !player:
		return
	velocity.x = 0
	var beamatk: BossBeam = beam.instantiate()
	beamatk.initialize(self, 3, damage, knockback)
	beamatk.global_position = global_position
	beamatk.global_position.y =player.global_position.y
	get_parent().add_child(beamatk)
	ranged_finished = true
	if player.global_position.x < global_position.x:
		$enemy_sprite.flip_h = true
	else:
		$enemy_sprite.flip_h = false
	sprite.play("beam")
	
func barrage_attack()-> void:
	if !player:
		return
	if shots_fired < 6:	
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
			shots_fired += 1
			if player.global_position.x < global_position.x:
				$enemy_sprite.flip_h = true
			else:
				$enemy_sprite.flip_h = false
			sprite.play("shoot")
	else:
		barrage_finished = true
		

	

func update_state(delta :float) -> void:
	if not player:
		return
	match current_state:
		State.Idle:
			idle_timer -= delta
			if idle_timer <= 0:
				var rngatk = randi() %3
				if rngatk == 0:
					current_state = State.Melee
					has_swung = false
					swing_delay = 0.5
					melee_timer = 2
				elif rngatk == 1:
					current_state = State.Barrage
					barrage_finished =false
					shots_fired = 0
					shoot_cd = 0
				else:
					current_state = State.Ranged
					ranged_finished = false
					
					
		State.Melee:
			melee_timer-= delta
			if has_swung or melee_timer <= 0:
				current_state = State.Idle
				idle_timer = 2
		State.Ranged:
			if ranged_finished:
				current_state = State.Idle
				idle_timer = 2
		State.Barrage:
			if barrage_finished:
				current_state = State.Idle
				idle_timer = 2
			
			
		
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	shoot_cd -= delta
	swing_delay -= delta
	update_state(delta)
	if current_state == State.Melee:
		print("melle state")
		boss_melee()
	if current_state == State.Idle:
		print("idle")
		velocity.x = 0
	if current_state == State.Barrage:
		print("barrage")
		barrage_attack()
	if current_state == State.Ranged:
		print("ranged")
		ranged_attack()
	if knockback_vector.length() > 0:
		knockback_vector = knockback_vector.lerp(Vector2.ZERO, delta*50)
		velocity += knockback_vector	
	if velocity.x != 0 && knockback_vector.length() <= 0:
		if velocity.x < 0:
			$enemy_sprite.flip_h = true
		else:
			$enemy_sprite.flip_h = false
		
		sprite.play("run")
	else:
		sprite.play("idle")
	move_and_slide()

func _ready():
	var game_manager = get_tree().get_first_node_in_group("GameManager")
	if game_manager:
		on_death.connect(game_manager.on_boss_death)
