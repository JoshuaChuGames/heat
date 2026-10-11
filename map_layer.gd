extends TileMapLayer
class_name MapLayer

func is_hazard_tile(position: Vector2) -> bool:
	position = to_local(position)
	var cell = local_to_map(position)
	var tile_data = get_cell_tile_data(cell)
	if tile_data.get_custom_data("is_hazard"):
		return true
	return false

func get_hazard_damage(position: Vector2) -> int:
	position = to_local(position)
	var cell = local_to_map(position)
	var tile_data = get_cell_tile_data(cell)
	if tile_data.get_custom_data("is_hazard"):
		return tile_data.get_custom_data("hazard_damage")
	return -1
