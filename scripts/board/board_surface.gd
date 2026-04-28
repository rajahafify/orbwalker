extends Control
class_name BoardSurface

@onready var _board_view: BoardView = %BoardView

func board_view() -> BoardView:
	return _board_view
