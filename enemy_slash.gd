extends EnemyAttack
class_name EnemySlash



func parried(kb: float) -> void:
	if enemy:
		var kb_vector = (enemy.global_position - global_position).normalized()
		enemy.apply_knockback(kb, global_position, kb_vector)

	
