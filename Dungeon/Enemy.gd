extends Reference

class_name EnemyScript
#
const TILE_SIZE = 32
#
var enemy = preload("res://Enemy.tscn")
#
var sprite_node
var tile # position on tile
var full_hp
var hp
var dead
#

func _init(root, x, y): # Root, x, y
	# initials
	tile = Vector2(x, y)
	sprite_node = enemy.instance()
	sprite_node.position = tile * TILE_SIZE
	root.add_child(sprite_node)
	
	# properties
	full_hp = 2
	hp = full_hp
	pass

func remove():
	sprite_node.queue_free()

func take_damage(game, dmg):
	# take damage
	hp = max(0, hp - dmg)
	# kill
	if hp == 0:
		dead = true
	if dead:
		return

func path(start, end, astar: AStar2D, astar_point_cache: Dictionary):
	var path = astar.get_point_path(start, end)
	print(path)
	return path

#func intelligence(rooms, player_pos):
##	var player_position = player_pos/32
#	# add points
#	var points_array = []
#	for r in rooms:
#		var point = r
#		points_array.append(point)
#		var point_index = calculate_index(point)
#		astar_node.add_point(point_index, Vector2(point.x, point.y))
#	# connect points
##	for point in points_array:
##		var point_index = calculate_index(point)
##		var points_relative = PoolVector2Array([
##			Vector2(point.x + 1, point.y),
##			Vector2(point.x - 1, point.y),
##			Vector2(point.x, point.y + 1),
##			Vector2(point.x, point.y - 1)])
##		for point_relative in points_relative:
##			var point_relative_index = calculate_index(point_relative)
##			if not astar_node.has_point(point_relative_index):
##				continue
##			astar_node.connect_points(point_index, point_relative_index, true)
#	var n = 0
#	for point in points_array: 
#		if n + 1 > (points_array.size() - 1):
#			break
#		else:
#			var next = points_array[n + 1]
#			var point_index = calculate_index(point)
#			var next_index = calculate_index(next)
#			astar_node.connect_points(point_index, next_index, true)
#			n += 1
#	# calculate
#	var start = calculate_index(tile)
#	var end = calculate_index(player_pos/32)
#	var path_array = astar_node.get_id_path(start, end)
##	var path = astar_node.get_point_position(path_array[1])
#	point_path = astar_node.get_point_path(start, end)
##	sprite_node.position = path * TILE_SIZE
#	print(start, " ", end, " ", path_array, " ", astar_node.get_points())
#
#func calculate_index(point):
#	return point.x + (10 * point.y)
