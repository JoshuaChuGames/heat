extends Enemy
class_name EnemyMelee


#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0
var enemy_slash = preload("res://enemy_slash.tscn")

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var attack_indicator: AnimatedSprite2D = $AttackIndicator




enum State{Idle,Patrol,Attacking, Agro, Lunging}


var current_state:State = State.Patrol
@export var speed = 100
@export var lunge_speed = 600
@export var lunge_distance = 400
@export var lunge_cooldown = 3
@export var lunge_duration = 3

@export var lunge_timer = 0
@export var change_direction_timer = 3
@export var move_direction = 1
@export var agro_distance = 600
@export var hp = 100
@export var damage = 10
@export var knockback = 300

var knockback_vector: Vector2

var lunge_vector: Vector2 = Vector2.ZERO

var timer_reached = false

@export var swing_cooldown = 2
@export var swing_delay = 0.25
@export var attack_distance = 200

@export var damage_flash_duration: float = 0.25
@export var damage_flash_total: int = 2

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
	if swing_cooldown <= 0 and swing_delay <= 0:
		var slash: EnemySlash = enemy_slash.instantiate()
		var dir_to_player = global_position.direction_to(player.global_position)
		slash.global_position = player.global_position
		slash.rotation = dir_to_player.angle() + deg_to_rad(90)
		slash.initialize(self, 0.25, damage, knockback, dir_to_player)
		get_parent().add_child(slash)
		swing_cooldown = 2
		swing_delay = 0.25

func show_attack_indicator() -> void:
	attack_indicator.visible = true
	attack_indicator.play("default")

func hide_attack_indicator() -> void:
	attack_indicator.visible = false

func wander_logic() -> void:	
	if move_direction < 1:
		$enemy_sprite.flip_h = true
	else:
		$enemy_sprite.flip_h = false
	velocity.x = speed * move_direction

func agro_logic() -> void:
	if player:
		if player.global_position.x < global_position.x:
			$enemy_sprite.flip_h = true
			velocity.x = speed * -1
		else:
			$enemy_sprite.flip_h = false
			velocity.x = speed
	
func idle_logic() -> void:
	velocity.x = 0
	
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
	move_and_slide()
		
func take_damage(damage: int) -> void:
	hp -= damage
	if hp <= 0:
		queue_free()
	damage_flash()

func apply_knockback(knockback: float, source_position: Vector2, kb_vector: Vector2 = Vector2.ZERO) -> void:
	if kb_vector != Vector2.ZERO:
		knockback_vector += kb_vector * knockback
	else:
		var knockback_direction = (global_position - source_position).normalized()
		knockback_vector += knockback_direction * knockback
		print(knockback_vector)

func damage_flash():
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_loops(damage_flash_total)
	tween.tween_property(material, "shader_parameter/flash_amount", 1.0, damage_flash_duration / 2)
	tween.tween_property(material, "shader_parameter/flash_amount", 0.0, damage_flash_duration / 2)
	tween.play()
