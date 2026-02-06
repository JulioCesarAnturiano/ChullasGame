extends Node2D

var hp: int = 600
var grid_pos: Vector2i = Vector2i.ZERO

# Dirección del último movimiento (se usa para disparar).S
# Por defecto: derecha
var last_dir: Vector2i = Vector2i(0, 1)

@onready var spr: Sprite2D = $Sprite2D

func _ready() -> void:
	# Cuadrado visible sin assets
	var img := Image.create(48, 48, false, Image.FORMAT_RGBA8)
	img.fill(Color(1.0, 0.0, 0.0, 1.0)) # Rojo
	var tex := ImageTexture.create_from_image(img)
	spr.texture = tex
	spr.centered = false

func set_last_dir(dir: Vector2i) -> void:
	# Solo acepta direcciones válidas (arriba/abajo/izq/der)
	if dir == Vector2i.ZERO:
		return
	last_dir = dir

func receive_damage(damage: int) -> bool:
	hp -= damage
	if hp <= 0:
		queue_free()
		return true
	return false
