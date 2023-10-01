extends Area2D

const BITMASK: int = 255	# Bitmask for terrain types

var current_terrain: int	# what terrain player is on
var previous_terrain: int	# previous terrain player was on
var current_tilemap: TileMap
var previous_tile_coords: Vector2i
var current_tile_coords: Vector2i
var mowed_tile: Vector2i = Vector2i(1, 0)

# Types of terrain the player can encounter
enum TerrainType {
	UNMOWED = 1,
	MOWED_LIGHT = 2,
	MOWED_DARK = 4,
	OBSTACLE = 8,
}

# Signals player with terrain type and coords
signal terrain_entered(terrain_type, terrain_coords)

# Triggers tilemap processing on colliding with new tile
func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body is TileMap:
		_process_tilemap_collision(body, body_rid)

# Gets tilemap, saving coords and getting terrain
func _process_tilemap_collision(body: Node2D, body_rid: RID):
	current_tilemap = body	# ref to tilemap
	
	# coords of current tile in map
	var collided_tile_coords = current_tilemap.get_coords_for_body_rid(body_rid)
	
	# For each layer get tile data
	# This is for having multiple layers for terrain
	for index in current_tilemap.get_layers_count():
		# Gets tile data for custom data layer
		var tile_data = current_tilemap.get_cell_tile_data(index, collided_tile_coords)
		if !tile_data is TileData:
			continue
		# Get terrain type
		var terrain_mask = tile_data.get_custom_data_by_layer_id(0)	# Terrain Layer
		# update terrain info to send to player
		_update_terrain(terrain_mask, collided_tile_coords)
		break
		

# Updates terrain info and sends to player
func _update_terrain(terrain_mask: int, new_coords: Vector2i):
	# Checks and updates terrain type (mowed/unmowed)
	if terrain_mask != current_terrain:
		previous_terrain = current_terrain
		current_terrain = terrain_mask
	# Checks and updates tile coords
	if new_coords != current_tile_coords:
		previous_tile_coords = current_tile_coords
		current_tile_coords = new_coords
	# Tell player terrain type and tile coords
	emit_signal("terrain_entered", current_terrain, current_tile_coords)

# "Mows" given tile by changing tile
func mow_tile(tile_pos: Vector2i):
	# Changes the cell to the mowed tile
	# set_cell(layer, coords, source_id, atlas_coords)
	# Layer is physics layers in tile set
	# coords is the cell position on map (game world)
	# source_id is the tile set source (found in tileset)
	# atlas_coords is the coords of the new tile in the atlas (found in tileset)
	current_tilemap.set_cell(0, tile_pos, 0, mowed_tile)
