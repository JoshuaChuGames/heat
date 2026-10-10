extends Control
class_name PlayerUI

@onready var health_bar: ResourceBar = $HealthBar
@onready var heat_gauge: ResourceBar = $HeatGauge

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
