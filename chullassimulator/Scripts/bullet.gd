extends Node2D

@export var speed_pixels_per_sec: float = 600.0
@onready var spr: Sprite2D = $Sprite2D

func set_texture(tex: Texture2D) -> void:
	if tex != null:
		spr.texture = tex
	spr.centered = false

func fly_to(target_pos: Vector2) -> void:
	var dist := position.distance_to(target_pos)
	var t := dist / speed_pixels_per_sec
	var tw := create_tween()
	tw.tween_property(self, "position", target_pos, t).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	await tw.finished
