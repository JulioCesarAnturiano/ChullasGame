extends Node2D

var hp: int = 200
var grid_pos: Vector2i = Vector2i.ZERO

@onready var spr: Sprite2D = $Sprite2D

func _ready() -> void:
	# Cuadrado visible sin assets
	var img := Image.create(48, 48, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.6, 0.6, 0.6, 1.0)) # Gris
	var tex := ImageTexture.create_from_image(img)
	spr.texture = tex
	spr.centered = false

func receive_damage(damage: int) -> bool:
	hp -= damage
	if hp <= 0:
		queue_free()
		return true
	return false
