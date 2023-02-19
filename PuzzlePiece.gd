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

export(Dictionary) var neighbors = {
	left = null,
	right = null,
	top = null,
	bottom = null
}

export(Dictionary) var hinge = {
	left = HingeState.NONE,
	right = HingeState.NONE,
	top = HingeState.NONE,
	bottom = HingeState.NONE
}

export var piece_scale: Vector2
onready var hinge_scale = piece_scale / 2

onready var polygon := $Polygon2D

func hinge(type: int, direction: Vector2) -> PoolVector2Array:
	# this is technically a "right hinge", so we can rotate it to be whatever hinge we want
	
	var angle := direction.angle()
	if type == HingeState.NONE:
		return PoolVector2Array([ piece_scale.rotated(angle) ])
	# since our puzzle piece is around (0, 0), we can use hinge_scale / 2 to define the hinge boundaries
	return PoolVector2Array([
		piece_scale.rotated(angle),
		Vector2(piece_scale.x, hinge_scale.y/2).rotated(angle),
		Vector2(piece_scale.x + hinge_scale.y * (1 if type == HingeState.EXTENDED else -1), hinge_scale.y/2).rotated(angle),
		Vector2(piece_scale.x + hinge_scale.y * (1 if type == HingeState.EXTENDED else -1), -hinge_scale.y/2).rotated(angle),
		Vector2(piece_scale.x, -hinge_scale.y/2).rotated(angle),
	])

func _ready() -> void:
	polygon.polygon = (
		hinge(hinge.right, Vector2.RIGHT)
		+ hinge(hinge.top, Vector2.UP)
		+ hinge(hinge.left, Vector2.LEFT)
		+ hinge(hinge.bottom, Vector2.DOWN)
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

# draws a black outline around the puzzle piece
func _draw():
	# get_polygon returns a clone, we dont want to reaccess it every time we get a polygon
	var poly = polygon.get_polygon()
	
	var color = Color(0,0,0)
	for i in range(1 , poly.size()):
		draw_line(poly[i-1], poly[i], color, 5)
	draw_line(poly[poly.size() - 1], poly[0], color, 5)
