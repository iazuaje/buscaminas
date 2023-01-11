extends Control

onready var trancisionEscena = $transicionDeEscenas
onready var panelFacil = $Records/HBoxContainer/PanelFacil
onready var panelMedio = $Records/HBoxContainer/Panelmedio
onready var panelDificil = $Records/HBoxContainer/PanelDificil

onready var clickSonido = $click_sonido

func _ready():
	panelFacil.setNombre("Fácil", SaveData.FACIL)
	panelMedio.setNombre("Intermedio", SaveData.INTERMEDIO)
	panelDificil.setNombre("Difícil", SaveData.DIFICIL)
	
	var diccionario = SaveData.cargar()
	panelFacil.setData(diccionario[SaveData.FACIL])
	panelMedio.setData(diccionario[SaveData.INTERMEDIO])
	panelDificil.setData(diccionario[SaveData.DIFICIL])

func _on_atras_pressed():
	trancisionEscena.transicionar(GLOBAL.escenaAnterior)
	clickSonido.play()
