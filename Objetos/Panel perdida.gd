class_name PanelVictoria
extends Control

signal reiniciar_presionado
signal salir_presionado

onready var reiniciarBoton = $Panel/HBoxContainer/Reiniciar
onready var salirBoton = $Panel/HBoxContainer/Salir

func activarBotones():
	reiniciarBoton.disabled = false
	salirBoton.disabled = false
	
func desactivarBotones():
	reiniciarBoton.disabled = true
	salirBoton.disabled = true

func _on_Reiniciar_pressed():
	emit_signal("reiniciar_presionado")

func _on_Salir_pressed():
	emit_signal("salir_presionado")
