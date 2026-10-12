extends Control
class_name PlayerUI

@onready var game_ui: Control = $GameUI
@onready var health_bar: ResourceBar = $GameUI/HealthBar
@onready var heat_gauge: ResourceBar = $GameUI/HeatGauge
@onready var game_over: Control = $GameOver
@onready var game_over_text: Label = $GameOver/Label
@onready var game_over_subtext: Label = $GameOver/Label2

signal on_retry
signal on_quit

func update_hp(current_hp: int = -1, max_hp: int = -1) -> void:
	if current_hp != -1:
		health_bar.value = current_hp
		if health_bar.current:
			health_bar.current.text = str(current_hp)
	if max_hp != -1:
		health_bar.max_value = max_hp
		if health_bar.maximum:
			health_bar.maximum.text = str(max_hp)

func update_heat(heat_progress: float = -1.0, total_heat: int = -1) -> void:
	if heat_progress != -1.0:
		heat_gauge.value = heat_progress   
	if total_heat != -1:
		if heat_gauge.total:
			heat_gauge.total.text = str(total_heat)

func show_game_over() -> void:
	game_over.show()
	game_ui.hide()

func show_game_ui() -> void:
	game_over.hide()
	game_ui.show()

func set_game_over_label(s: String):
	game_over_text.text = s
	
func set_game_over_sublabel(s: String):
	game_over_subtext.text = s
	
func retry():
	on_retry.emit()

func quit():
	on_quit.emit()
