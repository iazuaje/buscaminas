extends Control


onready var facilBoton = $Panel/HBoxContainer/facilBoton
onready var interBoton = $Panel/HBoxContainer/interBoton
onready var dificilBoton = $Panel/HBoxContainer/dificilBoton
onready var botonOk = $Panel/okNoton
onready var salirboton = $Panel/salir
onready var sonidoClick = $click_sonido

signal facilPresionado
signal intermedioPresionado
signal dificilPresionado
signal cerrarPresionado

enum botonPresionado {
	FACIL, INTERMEDIO, DIFICIL, NINGUNO
}

var eleccionFinal = botonPresionado.NINGUNO

func desactivarBotones():
	facilBoton.disabled = true
	interBoton.disabled = true
	dificilBoton.disabled = true
	botonOk.disabled = true
	salirboton.disabled = true

func reestablecer():
	facilBoton.disabled = false
	interBoton.disabled = false
	dificilBoton.disabled = false
	salirboton.disabled = false

func _on_facilBoton_toggled(button_pressed):
	sonidoClick.play()
	if !button_pressed: 
		eleccionFinal = botonPresionado.NINGUNO
		botonOk.disabled = true
		return
	botonOk.disabled = false
	eleccionFinal = botonPresionado.FACIL
	interBoton.set_pressed_no_signal(false)
	dificilBoton.set_pressed_no_signal(false)

func _on_interBoton_toggled(button_pressed):
	sonidoClick.play()
	if !button_pressed: 
		eleccionFinal = botonPresionado.NINGUNO
		botonOk.disabled = true
		return
	botonOk.disabled = false
	eleccionFinal = botonPresionado.INTERMEDIO
	facilBoton.set_pressed_no_signal(false)
	dificilBoton.set_pressed_no_signal(false)

func _on_dificilBoton_toggled(button_pressed):
	sonidoClick.play()
	if !button_pressed: 
		eleccionFinal = botonPresionado.NINGUNO
		botonOk.disabled = true
		return
	botonOk.disabled = false
	eleccionFinal = botonPresionado.DIFICIL
	interBoton.set_pressed_no_signal(false)
	facilBoton.set_pressed_no_signal(false)

func _on_okNoton_pressed():
	sonidoClick.play()
	desactivarBotones()
	match eleccionFinal:
		botonPresionado.FACIL:
			emit_signal("facilPresionado")
		botonPresionado.INTERMEDIO:
			emit_signal("intermedioPresionado")
		botonPresionado.DIFICIL:
			emit_signal("dificilPresionado")


func _on_salir_pressed():
	emit_signal("cerrarPresionado")
