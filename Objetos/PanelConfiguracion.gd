extends Control

const MAX_VOLUME = 10
const MIN_VOLUME = 10

var volumenFinal
var volumenInicial

onready var sliderVolumen = $Panel/HBoxContainer/HBoxContainer/MarginContainer/SliderVolumen
onready var infoVolumen = $Panel/HBoxContainer/HBoxContainer/infoVolumen
onready var sonido = $sonidoEjemplo
onready var clickSonido = $click_sonido

signal aceptarApretado
signal salirApretado

func _ready():
	volumenInicial = Config.configFile.get_value("audio", "volumenMaestro")
	sliderVolumen.value = volumenInicial + 90

func _on_SliderVolumen_value_changed(value):
	infoVolumen.text = "%02d%%" % value
	AudioServer.set_bus_volume_db(0, value - 90)

func _on_SliderVolumen_drag_ended(_value_changed):
	sonido.play()
	volumenFinal = sliderVolumen.value - 90

func _on_okBoton_pressed():
	Config.guardarConfiguracion(volumenFinal)
	emit_signal("aceptarApretado")
	clickSonido.play()

func _on_salir_pressed():
	AudioServer.set_bus_volume_db(0, volumenInicial)
	sliderVolumen.value = volumenInicial + 90
	emit_signal("salirApretado")
	clickSonido.play()
