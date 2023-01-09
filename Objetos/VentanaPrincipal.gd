extends Control

#Constantes
const CANTIDAD_COLUMMNAS : int = 8
const CANTIDAD_BOMBAS : int = 8
#Variables de editor
export(int) var columnas : int = CANTIDAD_COLUMMNAS
export(int) var bombas : int = CANTIDAD_BOMBAS

#Referencias a otras Escenas ajenas
var CasillaVacia = preload("res://Objetos/CasillaNoActiva.tscn")
var Cuadricula = preload("res://Objetos/Cuadricula.tscn")
var PanelDeVictoria = preload("res://Objetos/Panel perdida.tscn")

#Referencias a imagenes
var imagenBandera = preload("res://Recursos/Graficos/bandera.png")

#Referencias a nodos hijos
onready var contenedorPrincipal = $MarginContainer/VBoxContainer2
onready var contenedorCuadricula = $MarginContainer/VBoxContainer2/VBoxContainer
onready var panelGameOver = $gameOver
onready var display = $Display
onready var bombita = $bombita
onready var transicion = $Transicion
onready var animacion = $AnimationPlayer

#Variables
var container : Container = null
var botones : VBoxContainer = null
var casillasRestantes : int = 0
var panelVictoria : PanelVictoria = null
var visitados : Dictionary = {}
var cantidadCasillasAparecidas : int = 0
var primeraPartida : bool = true

# INICIO =======================================================================
func iniciar() -> void:
	animacion.play("iniciar")

func iniciarGrid() -> void:
	for y in range(columnas):
		for x in range(columnas):
			var casilla = CasillaVacia.instance()
			container.add_child(casilla)
			casilla.asignarCoordenada(Vector2(x,y))
			casilla.setIconoBandera(imagenBandera)
			casilla.connect("botonPresionado", self, "botonPresionado")

func generarBombas() -> void:
	var listaBombas : Array = []
	var cantidadCasillas : int = columnas * columnas
	var casillas : Array = container.get_children()
	for x in bombas:
		var coordenadaBomba = obtenerCoordenadaBomba(listaBombas, cantidadCasillas)
		listaBombas.append(coordenadaBomba)
		var casilla : CasillaNoActiva = casillas[coordenadaBomba]
		casilla.setBomba()

func obtenerCoordenadaBomba(listaBombas : Array, cantidadCasillas : int) -> int:
	var coordenadaBomba : int = randi() % cantidadCasillas
	if (!listaBombas.empty()):
		var nuevaCoordenadaEncontrada : bool = false
		while(!nuevaCoordenadaEncontrada):
			if coordenadaBomba in listaBombas:
				coordenadaBomba = randi() % cantidadCasillas
			else:
				nuevaCoordenadaEncontrada = true
	return coordenadaBomba

func obtenerAdyacentes(coordenada : Vector2) -> Array :
	var adyacentes : Array = []
	for y in range(-1, 2):
		for x in range(-1, 2):
			var posX = coordenada.x + x
			var posY = coordenada.y + y
			if ((posX >= 0 && posX < columnas) && (posY >= 0 && posY < columnas)):
				if (x != 0 || y != 0):
					adyacentes.append(pasarDeDosDimensionesAUna(Vector2(posX,posY)))
	return adyacentes

func pasarDeDosDimensionesAUna(vector2 : Vector2) -> int :
	return int((vector2.y * columnas) + vector2.x)

func asignarNumerosCasillas():
	var casillas : Array = container.get_children()
	for y in range(columnas):
		for x in range(columnas):
			var casillaActual : CasillaNoActiva = casillas[pasarDeDosDimensionesAUna(Vector2(x,y))]
			var adyacentes = obtenerAdyacentes(Vector2(x,y))
			for adyacente in adyacentes:
				var casillaAdyacente : CasillaNoActiva = casillas[adyacente]
				if casillaAdyacente.esBomba():
					casillaActual.aumentarCantidadBombas()

func configurarGrilla() -> void:
	container.columns = columnas
	iniciarGrid()
	generarBombas()
	asignarNumerosCasillas()
	casillasRestantes = columnas * columnas

func borrarGrilla() -> void:
	for casilla in container.get_children():
		container.remove_child(casilla)
		casilla.queue_free()
	container.queue_free()
# INICIO =======================================================================

# ETC ==========================================================================
func reiniciar():
	visitados.clear()
	if (!display.visible):
		display.text = "¡A jugar!"
		display.visible = true
	container = Cuadricula.instance()
	contenedorCuadricula.add_child(container)
	
	#configurarGrilla()

func botonPresionado(coordenadas: Vector2):
	var listaCasillas = container.get_children()
	var origen : CasillaNoActiva = listaCasillas[pasarDeDosDimensionesAUna(coordenadas)]
	
	if (origen.esBomba()):
		display.text = "! Oh no, explotaste !"
		game_over()
		return
	
	if (!origen.esVacia()):
		casillasRestantes -= 1
		display.text = "¡ Con cuidado D: !"
		origen.pintarNumeros()
		if (casillasRestantes == bombas):
			display.text = "¡ Muy bien !"
			victoria()
		return
	
	
	#DFS convencional
	casillasRestantes -= 1
	visitados[origen] = null
	var adyacentes : Array = obtenerAdyacentes(coordenadas)
	for adyacente in adyacentes:
		var casilla : CasillaNoActiva = listaCasillas[adyacente]
		if (!visitados.has(casilla)):
			visitados[casilla] = null
			if (!casilla.esBomba()):
				casilla.casillaPresionada()
	display.text = "¡Se despejó un poco :D !"

func desactivar_Botones():
	var listaCasillas = container.get_children()
	for x in range(columnas * columnas):
		var casilla : CasillaNoActiva = listaCasillas[x]
		casilla.disabled = true

func game_over():
	desactivar_Botones()
	panelGameOver.visible = true

func victoria():
	desactivar_Botones()
	if (panelVictoria == null):
		panelVictoria = PanelDeVictoria.instance()
# warning-ignore:return_value_discarded
		panelVictoria.connect("reiniciar_presionado", self, "reiniciarDesdeVictoria")
# warning-ignore:return_value_discarded
		panelVictoria.connect("salir_presionado", self, "_on_Salir_pressed")
	self.add_child(panelVictoria)

func reiniciarDesdeVictoria():
	self.remove_child(panelVictoria)
	_on_Reiniciar_pressed()
# ETC ==========================================================================

#Señales
func _on_iniciar_pressed():
	iniciar()

func _on_salir_pressed():
	get_tree().quit()

func _on_botoncito_pressed():
	OS.window_fullscreen = !OS.window_fullscreen

func _on_Reiniciar_pressed():
	if (primeraPartida): primeraPartida = false
	transicion.animar()
	panelGameOver.visible = false

func _on_Salir_pressed():
	_on_salir_pressed()

func _on_bombita_terminoAnimacionDesaparicion():
	transicion.animar()
	visitados.clear()
	if (!display.visible):
		display.visible = true
	container = Cuadricula.instance()
	contenedorCuadricula.add_child(container)

func _on_Transicion_mitadAnimacion():
	if (!primeraPartida):
		borrarGrilla()
		reiniciar()
	display.text = "¡A jugar!"
	configurarGrilla()
	bombita.visible = false

func _on_AnimationPlayer_animation_finished(_anim_name):
	#unica animacion por ahora
	transicion.animar()
	visitados.clear()
	if (!display.visible):
		display.visible = true
	container = Cuadricula.instance()
	contenedorCuadricula.add_child(container)
	botones = contenedorPrincipal.get_child(1)
	contenedorPrincipal.remove_child(botones)
