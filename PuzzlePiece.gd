extends Node2D

enum HingeState {
	EXTENDED,
	CONTRACTED,
	NONE
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
