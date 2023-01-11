extends Control


onready var nombreImput = $Control/nombreImput

signal nombreValido

func _on_aceptar_pressed():
	var nombre = nombreImput.text
	nombre = nombre.lstrip(" ")
	nombre = nombre.rstrip(" ")
	if (nombre.length() > 0):
		emit_signal("nombreValido", nombre)
