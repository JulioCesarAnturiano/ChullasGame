extends Node2D

var hp: int = 200
var grid_pos: Vector2i = Vector2i.ZERO

@export var tex_wall: Texture2D
@export var tex_wall_damaged: Texture2D
@export var damaged_threshold: int = 100 # Cuando hp <= 100, cambia a dañado

@onready var spr: Sprite2D = $Sprite2D

func _ready() -> void:
	if spr == null:
		push_error("Wall: Falta Sprite2D como hijo.")
		return
	_update_sprite()
	spr.centered = false

func receive_damage(damage: int) -> bool:
	hp -= damage
	_update_sprite()

	if hp <= 0:
		queue_free()
		return true
	return false

func _update_sprite() -> void:
	if spr == null:
		return

	if hp <= damaged_threshold and tex_wall_damaged != null:
		spr.texture = tex_wall_damaged
	elif tex_wall != null:
		spr.texture = tex_wall
