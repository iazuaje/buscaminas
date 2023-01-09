class_name CasillaNoActiva

extends Button

var cantidadBombasAdyacentes : int = 0
var soyBomba : bool = false
var coordenada = null
var estoyActiva : bool = false
var estoyPintada : bool = false
var tengoBandera : bool = false
var iconoBandera : Texture = null
var iconoBomba : Texture = null

onready var animacion : AnimationPlayer = $AnimationPlayer
onready var clickSonido : AudioStreamPlayer = $click_sonido

signal botonPresionado
signal descubrirBotonesAdyacentes

func asignarNombre(nombre : String) -> void:
	text = nombre

func asignarCoordenada(_coordenada : Vector2) -> void:
	coordenada = _coordenada

func setBomba() -> void:
	soyBomba = true

func setIconoBandera(imagen : Texture) -> void:
	iconoBandera = imagen

func setIconoBomba(imagen : Texture) -> void:
	iconoBomba = imagen

func esBomba() -> bool:
	return soyBomba

func esVacia() -> bool:
	return cantidadBombasAdyacentes == 0

func aumentarCantidadBombas() -> void:
	cantidadBombasAdyacentes += 1

func pintarNumeros() -> void:
	if cantidadBombasAdyacentes > 0 && text != "b":
		asignarColorCasilla()
		text = String(cantidadBombasAdyacentes)
		estoyPintada = true

func pintarBombas() -> void:
	icon = iconoBomba

func asignarColorCasilla():
	match cantidadBombasAdyacentes:
		0:
			pass
		1:
			set("custom_colors/font_color", Color.antiquewhite)
			set("custom_colors/font_color_focus", Color.antiquewhite)
			set("custom_colors/font_color_hover", Color.antiquewhite)
			set("custom_colors/font_color_pressed", Color.antiquewhite)
		2:
			set("custom_colors/font_color", Color.aqua)
			set("custom_colors/font_color_focus", Color.aqua)
			set("custom_colors/font_color_hover", Color.aqua)
			set("custom_colors/font_color_pressed", Color.aqua)
		3:
			set("custom_colors/font_color", Color.brown)
			set("custom_colors/font_color_focus", Color.brown)
			set("custom_colors/font_color_hover", Color.brown)
			set("custom_colors/font_color_pressed", Color.brown)
		4:
			set("custom_colors/font_color", Color.blueviolet)
			set("custom_colors/font_color_focus", Color.blueviolet)
			set("custom_colors/font_color_hover", Color.blueviolet)
			set("custom_colors/font_color_pressed", Color.blueviolet)
		5:
			set("custom_colors/font_color", Color.chocolate)
			set("custom_colors/font_color_focus", Color.chocolate)
			set("custom_colors/font_color_hover", Color.chocolate)
			set("custom_colors/font_color_pressed", Color.chocolate)
		6:
			set("custom_colors/font_color", Color.darkgreen)
			set("custom_colors/font_color_focus", Color.darkgreen)
			set("custom_colors/font_color_hover", Color.darkgreen)
			set("custom_colors/font_color_pressed", Color.darkgreen)
		7:
			set("custom_colors/font_color", Color.darkorange)
			set("custom_colors/font_color_focus", Color.darkorange)
			set("custom_colors/font_color_hover", Color.darkorange)
			set("custom_colors/font_color_pressed", Color.darkorange)
		8:
			set("custom_colors/font_color", Color.darkred)
			set("custom_colors/font_color_focus", Color.darkred)
			set("custom_colors/font_color_hover", Color.darkred)
			set("custom_colors/font_color_pressed", Color.darkred)
			

func casillaPresionada(buscarAdyacentes : bool) -> void:
	if disabled == false and !estoyActiva and !tengoBandera: animacion.play("click")
	if (!estoyActiva and not tengoBandera):
		if (esVacia()):
			disabled = true
		estoyActiva = true
		emit_signal("botonPresionado", coordenada)
	elif (estoyPintada and buscarAdyacentes):
		emit_signal("descubrirBotonesAdyacentes", coordenada)

func _on_CasillaNoActiva_gui_input(event) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			BUTTON_LEFT:
				if not disabled and not tengoBandera:
					casillaPresionada(true)
					clickSonido.play()
			BUTTON_RIGHT:
				if (!estoyPintada and not disabled):
					if (!tengoBandera):
						tengoBandera = true
						icon = iconoBandera
					else:
						tengoBandera = false
						icon = null
