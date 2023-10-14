extends Area2D

signal hit
signal passed_pipes

func _on_body_entered(body):
	hit.emit()


func _on_score_area_body_entered(body):
	passed_pipes.emit()
