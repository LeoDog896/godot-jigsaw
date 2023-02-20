extends Polygon2D

enum HingeState {
	EXTENDED = 0,
	CONTRACTED = 1,
	NONE = 2
}

export (int) var rows
export (int) var cols

export (int) var row
export (int) var col

export(HingeState) var top_hinge = HingeState.NONE
export(HingeState) var left_hinge = HingeState.NONE
export(HingeState) var right_hinge = HingeState.NONE
export(HingeState) var bottom_hinge = HingeState.NONE

export var piece_scale: Vector2

func hinge(type: int, direction: Vector2) -> PoolVector2Array:
	# this is technically a "right hinge", so we can rotate it to be whatever hinge we want
	
	var angle := direction.angle()
	
	# because puzzle pieces can be oriented differently we need to swap width and height depending on the direction
	var current_scale := piece_scale if direction.y == 0 else Vector2(piece_scale.y, piece_scale.x)
	if type == HingeState.NONE:
		return PoolVector2Array([ current_scale.rotated(angle) ])
	
	# since our puzzle piece is around (0, 0), we can use current_scale / 4 to define the hinge boundaries
	return PoolVector2Array([
		current_scale.rotated(angle),
		Vector2(current_scale.x, current_scale.y / 4).rotated(angle),
		Vector2(current_scale.x + current_scale.x / 2 * (1 if type == HingeState.EXTENDED else -1), current_scale.y / 4).rotated(angle),
		Vector2(current_scale.x + current_scale.x / 2 * (1 if type == HingeState.EXTENDED else -1), -current_scale.y / 4).rotated(angle),
		Vector2(current_scale.x, -current_scale.y / 4).rotated(angle),
	])

func _ready() -> void:
	polygon = (
		hinge(right_hinge, Vector2.RIGHT)
		+ hinge(top_hinge, Vector2.UP)
		+ hinge(left_hinge, Vector2.LEFT)
		+ hinge(bottom_hinge, Vector2.DOWN)
	)
	
	# we keep track of our own UV array since we can't append to it directly (the getter returns a clone)
	var localUV := []
	
	var IMAGE_WIDTH: int = texture.get_width() / cols
	var IMAGE_HEIGHT: int = texture.get_height() / rows
	
	for vertex in polygon:
		var normalized_vertex: Vector2 = (vertex / (piece_scale)) * (Vector2(IMAGE_WIDTH, IMAGE_HEIGHT) / 2)
		localUV.append(
			normalized_vertex 
			+ Vector2(
				IMAGE_WIDTH / 2 + (IMAGE_WIDTH * col),
				IMAGE_HEIGHT / 2 + (IMAGE_HEIGHT * row)
			)
		)
	
	uv = localUV
