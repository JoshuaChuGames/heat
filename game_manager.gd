extends Node2D

@export var game_scene: PackedScene
@onready var ui: PlayerUI = $CanvasLayer/PlayerUI

var game: Node2D
var player: Player
# Called when the node enters the scene tree for the first time.
func _ready():
	load_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_game():
	game = game_scene.instantiate()
	add_child(game)
	player = get_tree().get_first_node_in_group("Player")
	player.on_death.connect(on_player_death)

func on_player_death():
	ui.show_game_over()
	ui.set_game_over_label("Game Over")
	if player:
		ui.set_game_over_sublabel("Total Heat: " + str(max(player.heat.total_heat * 100 + player.heat.current_heat, 0)))

func on_boss_death():
	ui.show_game_over()
	ui.set_game_over_label("Victory!")
	if player:
		ui.set_game_over_sublabel("Total Heat: " + str(max(player.heat.total_heat * 100 + player.heat.current_heat, 0)))

func on_retry_pressed():
	ui.show_game_ui()
	game.queue_free()
	load_game()

func on_quit_pressed():
	get_tree().quit()
