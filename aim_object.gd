extends Node2D

@onready var slash_sprite: AnimatedSprite2D = $SlashSprite


func show_slash():
	slash_sprite.show()
	slash_sprite.play("slash")

func hide_slash():
	slash_sprite.hide()
	slash_sprite.stop()

func _process(delta):
	pass
