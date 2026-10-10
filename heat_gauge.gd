class_name HeatGauge

var heat_data: HeatGaugeData

var movement_speed: float = 0.0
var attack_speed: float = 0.0
var parry_speed: float = 0.0

func calculate_movement_multiplier():
	var k = heat_data.movement_speed_k
	var max = heat_data.movement_speed_max
	
	var multiplier = 1.0
	
	var diminishing_returns = movement_speed / (movement_speed + k)
	diminishing_returns *= max
	
	multiplier *= max(diminishing_returns, 1)
	
	return multiplier
