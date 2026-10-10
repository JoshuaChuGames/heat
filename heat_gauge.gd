class_name HeatGauge

var heat_data: HeatGaugeData

var current_heat: float = 0.0
var max_heat: float = 100
var total_heat: int = 0

var movement_speed_per_heat: float = 25.0
var attack_speed_per_heat: float = 25.0
var parry_speed_per_heat: float = 10.0

func calculate_movement_multiplier():
	var k = heat_data.movement_speed_k
	var max = heat_data.movement_speed_max
	var movement_speed = total_heat * movement_speed_per_heat
	
	var multiplier = 1.0
	
	var diminishing_returns = movement_speed / (movement_speed + k)
	diminishing_returns *= max
	
	multiplier *= max(diminishing_returns, 1)
	
	return multiplier

func calculate_attack_multiplier():
	var k = heat_data.attack_speed_k
	var max = heat_data.attack_speed_max
	var attack_speed = total_heat * attack_speed_per_heat
	
	var multiplier = 1.0
	
	var diminishing_returns = attack_speed / (attack_speed + k)
	diminishing_returns *= max
	
	multiplier *= max(diminishing_returns, 1)
	
	return multiplier

func calculate_parry_multiplier():
	var k = heat_data.parry_speed_k
	var max = heat_data.parry_speed_max
	var parry_speed = total_heat * parry_speed_per_heat
	
	var multiplier = 1.0
	
	var diminishing_returns = parry_speed / (parry_speed + k)
	diminishing_returns *= max
	
	multiplier *= max(diminishing_returns, 1)
	
	return multiplier

func increase_heat(amount: float):
	current_heat += amount
	if current_heat >= max_heat:
		current_heat = 0
		total_heat += 1
	
	return [current_heat, total_heat]