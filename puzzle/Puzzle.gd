extends Node2D

export (Texture) var texture

export (int) var rows = 0
export (int) var cols = 0

var puzzle_piece := preload("res://puzzle/PuzzlePiece.tscn")

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
		
		piece.row = n / cols
		piece.col = n % cols
		
		piece.texture = texture
		
		var neighbors := {
			top = null if piece.row == 0 else pieces[n - cols],
			left = null if piece.col == 0 else pieces[n - 1],
		}
		
		var image_size := Vector2(texture.get_width(), texture.get_height())
		
		piece.piece_scale = image_size / Vector2(cols, rows) * scale
		
		# we don't use a dictionary here since different values gives better editing in the editor UI
		piece.top_hinge = 2 if neighbors.top == null else _reverse_hinge(neighbors.top.bottom_hinge)
		piece.left_hinge = 2 if neighbors.left == null else _reverse_hinge(neighbors.left.right_hinge)
		piece.right_hinge = 2 if piece.col == cols - 1 else randi() % 2
		piece.bottom_hinge = 2 if piece.row == rows - 1 else randi() % 2
		
		piece.position = (piece.piece_scale * 2 * Vector2(piece.col, piece.row)) - (image_size * scale)
		
		pieces.append(piece)
	
	for piece in pieces:
		add_child(piece)
