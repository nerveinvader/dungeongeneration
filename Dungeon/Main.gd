extends Node2D

#
const WORLD_SIZE = 50 # tiles on x & y
const TILE_SIZE = 32 # tile map sizes

enum Tile {GROUND, WALL, LADDER} # 0, 1

onready var main = $"."
onready var tile_map = $TileMap
onready var player = $Player
onready var log_game = $CanvasLayer/RichTextLabel
#
var enemy = preload("res://Enemy.gd")
#
var player_tile

var map = []
var rooms = []

var pos_array = []
var enemies = []
var enemies_pos = []
#
var room_size = 4 # 0-9 on tile
var room_count = 25
var start_room
var end_room
var s_pos = Vector2(50, 50) # Astar need positive vectors (ShIT)

var rng = RandomNumberGenerator.new()
var rand

func _ready():
	
	# create little rooms w/ start & end
	# rooms of 4x4
#	create_room(room_size)
	pass
	

func _input(event):
	if !event.is_pressed():
		return
	# move the player & check next tile
	if event.is_action("ui_left"):
		try_move(-1, 0)
	if event.is_action("ui_up"):
		try_move(0, -1)
	if event.is_action("ui_right"):
		try_move(1, 0)
	if event.is_action("ui_down"):
		try_move(0, 1)
	
	if event.is_action("ui_accept"):
		create_level()
#		fill_map()
		_astar_data()

################################################# ADDITIONAL FUNCTIONS
######################## movement check
func try_move(dx, dy):
	player_tile = tile_map.world_to_map(player.position)
	var x = player_tile.x + dx
	var y = player_tile.y + dy
	var tile = tile_map.get_cell(x, y)
#	print(tile)
	
	# move if tile is:
	if tile == Tile.GROUND:
		var blocked = false
		for e in enemies:
			if e.tile.x == x && e.tile.y == y:
				print("blocked")
				e.take_damage([self], 1)
				log_game.text += "\n" + "You hit Enemy for 1 dmg"
				if e.dead:
					e.remove()
					enemies.erase(e)
				blocked = true
				break
		if !blocked:
			player.position.x += dx * 32
			player.position.y += dy * 32
			print(astar_node.are_points_connected(_astar_cache_return(start_room), _astar_cache_return(end_room)))
	
	if tile == Tile.LADDER:
		log_game.text += "\n" + "You entered a new Hallway"
		fill_map()
		_astar_data()
	
	for enemy in enemies:
		var start = _astar_cache_return(enemy.tile)
		var end = _astar_cache_return(player.position / 32)
		enemy.path(start, end, astar_node, astar_cache)
#		print(start, "-", end)
#		var path = astar_node.get_point_path(start, end)
#		print(path)
######################## AI?



######################## single room creator
func create_room(size):
	rng.randomize()
	for x in size:
		for y in size:
			var chance = rng.randi_range(0, 3)
#			if chance >= 1:
			tile_map.set_cell(x, y, Tile.GROUND)
			map.append(Vector2(x, y))
#			else:
#				y += 1
####################### level manager
func create_level():
	tile_map.clear()
	map.clear()
	create_room(room_size)
	start_room = map[0]
	end_room = map.back()
	player.position = start_room * 32
#	print(start_room)
#	print(end_room)
######################## random level generator
func fill_map():
	tile_map.clear()
	rooms.clear()
	for e in enemies:
		e.remove()
	enemies.clear()
	
	tile_map.set_cell(s_pos.x, s_pos.y, Tile.GROUND) # foundation
	rooms.append(s_pos) # starting room was not inside array
	for i in room_count:
		s_pos += rnd_dir()
		var occupied = tile_map.get_cell(s_pos.x, s_pos.y)
		if occupied < 0:
			tile_map.set_cell(s_pos.x, s_pos.y, Tile.GROUND)
			rooms.append(s_pos)
		else:
			i += 1
			room_count += 1
			room_count = min(room_count, 25)
	start_room = rooms[0]
	end_room = rooms.back()
	tile_map.set_cell(end_room.x, end_room.y, Tile.LADDER)
	player.position = start_room * 32
	
	pos_array = rooms.duplicate()
	pos_array.remove(0)
#	print(pos_array, "/ ", rooms)
	place_enemy(1)
	print(end_room)
	s_pos = end_room
	print(s_pos)
######################## random direction by degree generator
func rnd_dir():
	rng.randomize()
	var degree = (rng.randi() % 4) * 90
	# return direction based on degree
	# top, right, bot, left
	if degree == 0:
		return Vector2(0, -1)
	if degree == 90:
		return Vector2(1, 0)
	if degree == 180:
		return Vector2(0, 1)
	if degree == 270:
		return Vector2(-1, 0)
######################## create & place enemies
func place_enemy(count):
	rng.randomize()
	var total = count
	var last_pos = Vector2(0, 0)
	for i in count: # this many
		var pos = pos_array[rng.randi() % pos_array.size()] # return vector
		if pos != rooms[0] && pos != rooms.back():
			if pos != last_pos:
				# place enemy in one random location
				var new_enemy = enemy.new(main, pos.x, pos.y)
				enemies.append(new_enemy)
#				enemies_pos.append(pos)
				last_pos = pos
		elif count < total:
			count += 1
		else:
			break
########################

var astar_node = AStar2D.new()
var point_path = []
var astar_cache = {}

func _astar_data():
	#add points
	var points_array = []
	for r in map:
		var point = r
		points_array.append(point)
		var point_index = astar_node.get_available_point_id() #calculate_index(point)
		astar_node.add_point(point_index, Vector2(point.x, point.y))
		astar_cache[str(point.x, point.y)] = point_index
	# connect points
#	for point in points_array:
#		var point_index = calculate_index(point)
		var points_relative = PoolVector2Array([
			Vector2(point.x + 1, point.y),
			Vector2(point.x - 1, point.y),
			Vector2(point.x, point.y + 1),
			Vector2(point.x, point.y - 1)])
		for point_relative in points_relative:
			var point_relative_index = astar_node.get_available_point_id()
			if not astar_node.has_point(point_relative_index):
				continue
			astar_node.connect_points(point_index, point_relative_index, true)
	print(astar_node.get_points(), " // ", astar_cache.keys())

func _astar_cache_return(point):
	return astar_cache[str(point.x, point.y)]
