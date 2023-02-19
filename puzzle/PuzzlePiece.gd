extends Node2D

enum HingeState {
	EXTENDED = 0,
	CONTRACTED = 1,
	NONE = 2
}

export (int) var rows
export (int) var cols

export (int) var row
export (int) var col

export (Texture) var texture

export(HingeState) var top_hinge = HingeState.NONE
export(HingeState) var left_hinge = HingeState.NONE
export(HingeState) var right_hinge = HingeState.NONE
export(HingeState) var bottom_hinge = HingeState.NONE

export var piece_scale: Vector2

onready var polygon := $Polygon2D

func hinge(type: int, direction: Vector2) -> PoolVector2Array:
	# this is technically a "right hinge", so we can rotate it to be whatever hinge we want
	
	var angle := direction.angle()
	if type == HingeState.NONE:
		return PoolVector2Array([ piece_scale.rotated(angle) ])
	
	# since our puzzle piece is around (0, 0), we can use piece_scale / 4 to define the hinge boundaries
	return PoolVector2Array([
		piece_scale.rotated(angle),
		Vector2(piece_scale.x, piece_scale.y / 4).rotated(angle),
		Vector2(piece_scale.x + piece_scale.y / 2 * (1 if type == HingeState.EXTENDED else -1), piece_scale.y / 4).rotated(angle),
		Vector2(piece_scale.x + piece_scale.y / 2 * (1 if type == HingeState.EXTENDED else -1), -piece_scale.y / 4).rotated(angle),
		Vector2(piece_scale.x, -piece_scale.y / 4).rotated(angle),
	])

func _ready() -> void:
	polygon.polygon = (
		hinge(right_hinge, Vector2.RIGHT)
		+ hinge(top_hinge, Vector2.UP)
		+ hinge(left_hinge, Vector2.LEFT)
		+ hinge(bottom_hinge, Vector2.DOWN)
	)
	
	polygon.texture = texture
	
	var localUV := []
	
	var IMAGE_WIDTH: int = texture.get_width() / cols
	var IMAGE_HEIGHT: int = texture.get_height() / rows
	
	for vertex in polygon.polygon:
		var normalized_vertex: Vector2 = (vertex / (piece_scale)) * (IMAGE_WIDTH / 2)
		localUV.append(
			normalized_vertex 
			+ Vector2(
				IMAGE_WIDTH / 2 + (IMAGE_WIDTH * col),
				IMAGE_HEIGHT / 2 + (IMAGE_HEIGHT * row)
			)
		)
	
	polygon.uv = localUV
