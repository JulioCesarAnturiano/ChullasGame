extends Node2D

var hp: int = 600
var grid_pos: Vector2i = Vector2i.ZERO
var last_dir: Vector2i = Vector2i(0, 1)

@export var tex_chulla: Texture2D

@onready var spr: Sprite2D = $Sprite2D

func _ready() -> void:
	if spr == null:
		push_error("Chulla: Falta Sprite2D como hijo.")
		return
	if tex_chulla != null:
		spr.texture = tex_chulla
	spr.centered = false

func set_last_dir(dir: Vector2i) -> void:
	if dir == Vector2i.ZERO:
		return
	last_dir = dir

func receive_damage(damage: int) -> bool:
	hp -= damage
	if hp <= 0:
		queue_free()
		return true
	return false

func set_aim(dir: Vector2i) -> void:
	if dir == Vector2i.ZERO:
		return
	last_dir = dir

	# Rotación según dirección (arriba/abajo/izq/der)
	var angle := 0.0
	if dir == Vector2i(-1, 0): # arriba
		angle = -PI / 2
	elif dir == Vector2i(1, 0): # abajo
		angle = PI / 2
	elif dir == Vector2i(0, -1): # izquierda
		angle = PI
	elif dir == Vector2i(0, 1): # derecha
		angle = 0.0

	$Sprite2D.rotation = angle
