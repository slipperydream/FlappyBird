extends CanvasLayer

signal exit_game
signal restart_game

func _on_restart_button_pressed():
	restart_game.emit()


func _on_quit_button_pressed():
	exit_game.emit()
