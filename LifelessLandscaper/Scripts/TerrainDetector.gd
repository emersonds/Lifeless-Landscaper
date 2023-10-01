extends Area2D

const BITMASK: int = 255

var current_terrain: int
var previous_terrain: int
var current_tilemap: TileMap
var previous_tile_coords: Vector2i
var current_tile_coords: Vector2i

enum TerrainType {
	UNMOWED = 1,
	MOWED_LIGHT = 2,
	MOWED_DARK = 4,
	OBSTACLE = 8,
}

signal terrain_entered(terrain_type, terrain_coords)

func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body is TileMap:
		_process_tilemap_collision(body, body_rid)


func _process_tilemap_collision(body: Node2D, body_rid: RID):
	current_tilemap = body
	
	var collided_tile_coords = current_tilemap.get_coords_for_body_rid(body_rid)
	
	for index in current_tilemap.get_layers_count():
		var tile_data = current_tilemap.get_cell_tile_data(index, collided_tile_coords)
		if !tile_data is TileData:
			continue
		var terrain_mask = tile_data.get_custom_data_by_layer_id(0)	# Terrain Layer
		_update_terrain(terrain_mask, collided_tile_coords)
		break
		

func _update_terrain(terrain_mask: int, new_coords: Vector2i):
	if terrain_mask != current_terrain:
		previous_terrain = current_terrain
		current_terrain = terrain_mask
	if new_coords != current_tile_coords:
		previous_tile_coords = current_tile_coords
		current_tile_coords = new_coords
		print(current_tile_coords)
	emit_signal("terrain_entered", current_terrain, current_tile_coords)

func mow_tile(tile_pos: Vector2i):
	current_tilemap.set_cell(0, tile_pos, 0, Vector2i(1, 0))
