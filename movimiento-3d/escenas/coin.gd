extends Area3D

func _on_body_entered(body: Node3D) -> void:
	# Si lo que entra en el área es el jugador, se elimina la moneda
	if body is CharacterBody3D:
		queue_free()
