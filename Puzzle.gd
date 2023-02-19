extends Node2D

export (Texture) var texture

export (int) var rows = 0
export (int) var cols = 0

var puzzle_piece := preload("res://PuzzlePiece.tscn")

func _reverse_hinge(hinge: int) -> int:
	return 0 if hinge == 1 else 1

func _ready():
	var pieces: Array = []
	
	for n in rows * cols:
		var piece := puzzle_piece.instance()

		# we need to pass down context info to the puzzle piece
		# from the parent to keep it isolated
		piece.rows = rows
		piece.cols = cols
		
		piece.row = n / rows
		piece.col = n % cols
		
		piece.texture = texture
		
		# we use neighbor.* as tracking variables on the Node,
		# the puzzle piece class doesn't have any use for them.
		piece.neighbors = {
			top = null if piece.row == 0 else pieces[n - cols * piece.row],
			left = null if piece.col == 0 else pieces[n - 1],
			right = null,
			bottom = null
		}
		
		var image_size := Vector2(texture.get_width(), texture.get_height())
		
		piece.piece_scale = image_size / Vector2(cols, rows) * scale
		
		piece.hinge = {
			top = 2 if piece.neighbors.top == null else _reverse_hinge(piece.neighbors.top.hinge.bottom),
			left = 2 if piece.neighbors.left == null else _reverse_hinge(piece.neighbors.left.hinge.right),
			right = 2 if piece.col == cols - 1 else randi() % 2,
			bottom = 2 if piece.row == rows - 1 else randi() % 2
		}
		
		if piece.neighbors.top != null:
			piece.neighbors.top.neighbors.bottom = piece
		
		if piece.neighbors.left != null:
			piece.neighbors.left.neighbors.right = piece
		
		piece.position = (piece.piece_scale * 2 * Vector2(piece.col, piece.row)) - image_size * scale
		
		pieces.append(piece)
	
	for piece in pieces:
		add_child(piece)
