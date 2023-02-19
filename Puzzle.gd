extends Node2D

export (Texture) var texture

export (int) var rows = 0
export (int) var cols = 0

onready var puzzle_piece = preload("res://PuzzlePiece.tscn")

func _reverse_hinge(hinge: int) -> int:
	if hinge == 1:
		return 0
	else:
		return 1

func _ready():
	var pieces: Array = []
	
	for n in rows * cols:
		var piece = puzzle_piece.instance()

		# we need to pass down context info to the puzzle piece
		# from the parent to keep it isolated
		piece.rows = rows
		piece.cols = cols
		
		piece.row = n / rows
		piece.col = n % cols
		
		piece.texture = texture
		
		# we use %s_neighbor as tracking variables on the Node,
		# the puzzle piece class doesn't have any use for them.
		piece.neighbors.top = null if piece.row == 0 else pieces[n - cols * piece.row]
		piece.neighbors.left = null if piece.col == 0 else pieces[n - 1]
		piece.neighbors.right = null
		piece.neighbors.bottom = null
		
		if piece.neighbors.top != null:
			piece.neighbors.top.neighbors.bottom = piece
		
		if piece.neighbors.left != null:
			piece.neighbors.left.neighbors.right = piece
		
		piece.piece_scale = Vector2(texture.get_width() / cols, texture.get_height() / rows) * scale
		
		piece.hinge.top = 2 if piece.neighbors.top == null else _reverse_hinge(piece.neighbors.top.hinge.bottom)
		piece.hinge.left = 2 if piece.neighbors.left == null else _reverse_hinge(piece.neighbors.left.hinge.right)
		piece.hinge.right = 2 if piece.col == cols - 1 else randi() % 2
		piece.hinge.bottom = 2 if piece.row == rows - 1 else randi() % 2
		
		pieces.append(piece)
	
	for piece in pieces:
		add_child(piece)
