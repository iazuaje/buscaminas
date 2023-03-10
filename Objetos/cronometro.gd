extends Control

onready var minutos = $HBoxContainer/minutos
onready var segundos = $HBoxContainer/segundos
onready var milisegundos = $HBoxContainer/milisegundos

func asignarTexto(_minutos : int, _segundos : int, _milisegundos : int) -> void:
	minutos.text = "%02d" % _minutos
	segundos.text = "%02d" % _segundos
	milisegundos.text = "%02d" % _milisegundos

func obtenerTiempo():
	var lista = []
	lista.append(minutos.text)
	lista.append(segundos.text)
	lista.append(milisegundos.text)
	return "".join(lista)
