extends Area3D

# señal
func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		queue_free() # elimina la moneda si se agarra
