
extends Node2D

@export var rows: int = 9
@export var cols: int = 9
@export var cell_size: int = 48


@export var chulla_scene: PackedScene
@export var wall_scene: PackedScene

@onready var entities: Node2D = $Entities
@onready var board: Node2D = $Board
@onready var turn_label: Label = $UI/Label
@onready var info_label: Label = $UI/Label2
@export var floor_texture: Texture2D
@export var bullet_scene: PackedScene
@export var bullet_texture: Texture2D



var grid: Array = []


var current_player: int = 0
var chullas: Array = [] 
var game_over: bool = false
var last_dir: Vector2i = Vector2i(0, 1) 
var damage_projectile: int = 200        


func _ready() -> void:
	_init_grid()
	_draw_floor()
	_setup_level()
	_update_ui()


# -------------------------
# Inicialización De Matriz
# -------------------------
func _init_grid() -> void:
	grid.clear()
	for r in range(rows):
		var row_arr: Array = []
		row_arr.resize(cols)
		for c in range(cols):
			row_arr[c] = null
		grid.append(row_arr)

func _draw_floor() -> void:
	# Limpia el Board
	for child in board.get_children():
		child.queue_free()

	if floor_texture == null:
		return

	for r in range(rows):
		for c in range(cols):
			var s := Sprite2D.new()
			s.texture = floor_texture
			s.centered = false
			s.position = Vector2(c * cell_size, r * cell_size)
			board.add_child(s)


# -------------------------
# Conversión Celda <-> Mundo
# -------------------------
func board_to_world(cell: Vector2i) -> Vector2:
	# Nota: X = Columna, Y = Fila
	return Vector2(cell.y * cell_size, cell.x * cell_size)


func is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < rows and cell.y >= 0 and cell.y < cols


func get_at(cell: Vector2i) -> Variant:
	return grid[cell.x][cell.y]


func set_at(cell: Vector2i, value: Variant) -> void:
	grid[cell.x][cell.y] = value


# -------------------------
# Spawns
# -------------------------
func _spawn_wall(cell: Vector2i, hp: int = 200) -> Node2D:
	if wall_scene == null:
		push_error("Falta Asignar wall_scene En El Inspector.")
		return null
	if not is_inside(cell):
		return null
	if get_at(cell) != null:
		return null

	var wall: Node2D = wall_scene.instantiate() as Node2D
	entities.add_child(wall)
	wall.position = board_to_world(cell)
	wall.set("grid_pos", cell)
	wall.set("hp", hp)
	set_at(cell, wall)
	return wall


func _spawn_chulla(cell: Vector2i, hp: int = 600) -> Node2D:
	if chulla_scene == null:
		push_error("Falta Asignar chulla_scene En El Inspector.")
		return null
	if not is_inside(cell):
		return null
	if get_at(cell) != null:
		return null

	var chulla: Node2D = chulla_scene.instantiate() as Node2D
	entities.add_child(chulla)
	chulla.position = board_to_world(cell)
	chulla.set("grid_pos", cell)
	chulla.set("hp", hp)
	set_at(cell, chulla)
	return chulla


# -------------------------
# Nivel De Prueba
# -------------------------
func _setup_level() -> void:
	# Limpia Todo Lo Instanciado En Entities
	for child in entities.get_children():
		child.queue_free()

	_init_grid()
	chullas.clear()
	current_player = 0
	game_over = false

	# Dos Chullas En Esquinas
	var c1: Node2D = _spawn_chulla(Vector2i(rows - 1, 0), 600)
	var c2: Node2D = _spawn_chulla(Vector2i(0, cols - 1), 600)
	if c1 != null:
		chullas.append(c1)
	if c2 != null:
		chullas.append(c2)

	# Muro En El Centro
	var mid: Vector2i = Vector2i(rows / 2, cols / 2)
	_spawn_wall(mid, 200)


# -------------------------
# UI
# -------------------------
func _update_ui() -> void:
	if turn_label:
		var name: String = "Chulla " + str(current_player + 1)
		turn_label.text = "Turno: " + name

	if info_label and chullas.size() == 2:
		var hp1: int = int(chullas[0].get("hp"))
		var hp2: int = int(chullas[1].get("hp"))
		info_label.text = "HP1: %d | HP2: %d" % [hp1, hp2]


# -------------------------
# Entrada Básica
# -------------------------
func _unhandled_input(event: InputEvent) -> void:
	if game_over:
		return
	if chullas.size() < 2:
		return

	var chulla: Node2D = chullas[current_player] as Node2D

	# Flechas: solo apuntar (no mover)
	if event.is_action_pressed("ui_up"):
		last_dir = Vector2i(-1, 0)
		chulla.call("set_aim", last_dir)
		return
	elif event.is_action_pressed("ui_down"):
		last_dir = Vector2i(1, 0)
		chulla.call("set_aim", last_dir)
		return
	elif event.is_action_pressed("ui_left"):
		last_dir = Vector2i(0, -1)
		chulla.call("set_aim", last_dir)
		return
	elif event.is_action_pressed("ui_right"):
		last_dir = Vector2i(0, 1)
		chulla.call("set_aim", last_dir)
		return

	# M + flecha: mover (una acción por turno)
	if event.is_action_pressed("move"):
		# Mueve en la dirección donde está apuntando
		move_current(last_dir)
		end_turn()
		return

	# Space: disparar
	if event.is_action_pressed("shoot"):
		shoot_current()
		return

	if game_over:
		return
	if chullas.size() < 2:
		return

	if event.is_action_pressed("ui_up"):
		last_dir = Vector2i(-1, 0)
		move_current(last_dir)
		end_turn()
	elif event.is_action_pressed("ui_down"):
		last_dir = Vector2i(1, 0)
		move_current(last_dir)
		end_turn()
	elif event.is_action_pressed("ui_left"):
		last_dir = Vector2i(0, -1)
		move_current(last_dir)
		end_turn()
	elif event.is_action_pressed("ui_right"):
		last_dir = Vector2i(0, 1)
		move_current(last_dir)
		end_turn()
	elif event.is_action_pressed("shoot"):
		shoot_current()
	elif event.is_action_pressed("ui_accept"):
		end_turn()


# -------------------------
# Movimiento
# -------------------------
func move_current(dir: Vector2i) -> void:
	var chulla: Node2D = chullas[current_player] as Node2D
	var from_cell: Vector2i = chulla.get("grid_pos") as Vector2i
	var to_cell: Vector2i = from_cell + dir

	if not is_inside(to_cell):
		return
	if get_at(to_cell) != null:
		return

	set_at(from_cell, null)
	set_at(to_cell, chulla)

	chulla.set("grid_pos", to_cell)
	chulla.position = board_to_world(to_cell)

	_update_ui()
func shoot_current() -> void:
	if chullas.size() < 2:
		return

	var shooter: Node2D = chullas[current_player] as Node2D
	var start_cell: Vector2i = shooter.get("grid_pos") as Vector2i
	var cell: Vector2i = start_cell + last_dir

	# Crear bala visual
	var bullet: Node2D = null
	if bullet_scene != null:
		bullet = bullet_scene.instantiate() as Node2D
		entities.add_child(bullet)
		bullet.position = shooter.position
		if bullet.has_method("set_texture"):
			bullet.call("set_texture", bullet_texture)

	while is_inside(cell):
		var next_pos := board_to_world(cell)

		# Mover bala visual a la siguiente celda
		if bullet != null and bullet.has_method("fly_to"):
			await bullet.call("fly_to", next_pos)

		var target: Variant = get_at(cell)

		if target == null:
			cell += last_dir
			continue

		_apply_damage_to_target(target as Node)
		_update_ui()
		_check_game_over()

		if bullet != null:
			bullet.queue_free()

		end_turn()
		return

	# No golpeó nada
	if bullet != null:
		bullet.queue_free()
	end_turn()


func _apply_damage_to_target(target: Node) -> void:
	# Reglas:
	# - Wall: daño completo
	# - Chulla: daño a la mitad
	var dmg: int = damage_projectile
	
	var is_chulla: bool = target.has_method("set_last_dir")
	if is_chulla:
		dmg = dmg / 2
	# Aplicar daño
	if target.has_method("receive_damage"):
		var destroyed: bool = bool(target.call("receive_damage", dmg))
		# Si se destruyó, limpiar su celda en la matriz
		# grid_pos siempre lo seteamos desde game.gd al spawnear
		if destroyed:
			var cell: Vector2i = target.get("grid_pos") as Vector2i
			set_at(cell, null)


func _check_game_over() -> void:
	# Si una chulla fue destruida, termina el juego
	var alive := 0
	for c in chullas:
		if is_instance_valid(c):
			alive += 1

	if alive < 2:
		game_over = true
		if turn_label:
			turn_label.text = "Fin Del Juego"


func end_turn() -> void:
	current_player = 1 - current_player
	_update_ui()
