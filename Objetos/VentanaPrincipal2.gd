extends Control

#Constantes
const CANTIDAD_COLUMMNAS : int = 8
const CANTIDAD_BOMBAS : int = 8
const CANTIDAD_MAX_FILAS : int = 13
#Variables de editor
export(int) var columnas : int = CANTIDAD_COLUMMNAS
export(int) var filas : int = CANTIDAD_COLUMMNAS
export(int) var bombas : int = CANTIDAD_BOMBAS

#Referencias a otras Escenas ajenas
var CasillaVacia = preload("res://Objetos/CasillaNoActiva.tscn")
var Cuadricula = preload("res://Objetos/Cuadricula.tscn")
var Notificacion = preload("res://Objetos/Notificacion.tscn")

#Referencias a imagenes
var imagenBandera = preload("res://Recursos/Graficos/bandera.png")
var imagenBomba = preload("res://Recursos/Graficos/logo.png")

#Referencias a nodos hijos
onready var contenedorCuadricula = $contenedorCuadricula
onready var panelGameOver = $gameOver
onready var display = $Display
onready var bombita = $bombita
onready var transicion = $Transicion
onready var animacion = $AnimationPlayer
onready var panelDeVictoria = $PanelDeVictoria
onready var panelDificultad = $panelDificultad
onready var panelConfiguracion = $PanelConfiguracion
onready var botonDificultad = $dificultadBoton
onready var tiempoLabel = $cronometro
onready var httpRequest = $HTTPRequest

onready var transicionDeEscena = $transicionDeEscenas

#Referencias nodos sonido
onready var sonidoVictoria = $victoria_sonido
onready var sonidoGameOver = $game_over_sonido
onready var sonidoClick = $click_sonido

#Variables
var container : Container = null
var botones : VBoxContainer = null
var casillasRestantes : int = 0
var visitados : Dictionary = {}
var cantidadCasillasAparecidas : int = 0
var primeraPartida : bool = true
var primerClick : bool
var tiempoDePartida : float = 0
var partidaEnCurso : bool = false
var partidaPerdida : bool
var dificultad : String

# CALCULO DE TIEMPO ============================================================
func _ready():
	randomize()
	httpRequest.connect("request_completed", self, "_on_request_completed")
	var error = httpRequest.request("https://raw.githubusercontent.com/iazuaje/buscaminas/master/version.json")
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		
func _on_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var versionNueva = json.result["version"]
	if (versionNueva != GLOBAL.versionActual):
		var notificacion = Notificacion.instance()
		add_child(notificacion)

func _process(delta : float) -> void:
	if (partidaEnCurso):
		tiempoDePartida += delta
		var minutos = tiempoDePartida / 60
		var segundos = fmod(tiempoDePartida, 60)
		var milisegundos = fmod(tiempoDePartida, 1) * 100
		tiempoLabel.asignarTexto(minutos, segundos, milisegundos)

# INICIO =======================================================================
func iniciar() -> void:
	animacion.play("iniciar")

func iniciarGrid() -> void:
	for y in range(filas):
		for x in range(columnas):
			var casilla = CasillaVacia.instance()
			container.add_child(casilla)
			casilla.asignarCoordenada(Vector2(x,y))
			casilla.setIconoBandera(imagenBandera)
			casilla.setIconoBomba(imagenBomba)
			casilla.connect("botonPresionado", self, "botonPresionado")
			casilla.connect("descubrirBotonesAdyacentes", self, "descubrirBotonesAdyacentes")

func generarBombas(posicionPrimeraCasilla : int) -> void:
	var listaBombas : Array = []
	listaBombas.append(posicionPrimeraCasilla)
	var cantidadCasillas : int = columnas * filas
	var casillas : Array = container.get_children()
	for x in bombas:
		var coordenadaBomba = obtenerCoordenadaBomba(listaBombas, cantidadCasillas)
		listaBombas.append(coordenadaBomba)
		var casilla = casillas[coordenadaBomba]
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
	#Devuelve las coordenadas en 1D de las casillas adyacentes
	var adyacentes : Array = []
	for y in range(-1, 2):
		for x in range(-1, 2):
			var posX = coordenada.x + x
			var posY = coordenada.y + y
			if ((posX >= 0 && posX < columnas) && (posY >= 0 && posY < filas)):
				if (x != 0 || y != 0):
					adyacentes.append(pasarDeDosDimensionesAUna(Vector2(posX,posY)))
	return adyacentes

func pasarDeDosDimensionesAUna(vector2 : Vector2) -> int :
	return int((vector2.y * columnas) + vector2.x)

func asignarNumerosCasillas():
	var casillas : Array = container.get_children()
	for y in range(filas):
		for x in range(columnas):
			var casillaActual = casillas[pasarDeDosDimensionesAUna(Vector2(x,y))]
			var adyacentes = obtenerAdyacentes(Vector2(x,y))
			for adyacente in adyacentes:
				var casillaAdyacente = casillas[adyacente]
				if casillaAdyacente.esBomba():
					casillaActual.aumentarCantidadBombas()

func configurarGrilla() -> void:
	container.columns = columnas
	iniciarGrid()
	casillasRestantes = columnas * filas

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

func verificarGameOver():
	var listaCasillas = container.get_children()
	var cantidadCasillasRestantes : int = 0
	for casilla in listaCasillas:
		if (!casilla.estoyActiva):
			cantidadCasillasRestantes += 1
	if cantidadCasillasRestantes == bombas and not partidaPerdida:
		display.text = "¡ Muy bien !"
		victoria()

func botonPresionado(coordenadas: Vector2) -> void:
	var listaCasillas = container.get_children()
	var origen = listaCasillas[pasarDeDosDimensionesAUna(coordenadas)]
	
	#Primer click y configurado de la pantalla
	if(primerClick):
		partidaEnCurso = true
		partidaPerdida = false
		primerClick = false
		generarBombas(pasarDeDosDimensionesAUna(coordenadas))
		asignarNumerosCasillas()
		if (!origen.esVacia()):
			origen.disabled = false
	
	if (origen.esBomba()):
		display.text = "! Oh no, explotaste !"
		partidaPerdida = true
		game_over()
		return
	
	if (!origen.esVacia()):
		casillasRestantes -= 1
		display.text = "¡ Con cuidado D: !"
		origen.pintarNumeros()
		verificarGameOver()
		return
	
	#DFS convencional
	casillasRestantes -= 1
	visitados[origen] = null
	var adyacentes : Array = obtenerAdyacentes(coordenadas)
	for adyacente in adyacentes:
		var casilla = listaCasillas[adyacente]
		if (!visitados.has(casilla)):
			visitados[casilla] = null
			if (!casilla.esBomba()):
				casilla.casillaPresionada(false)
	display.text = "¡Se despejó un poco :D !"

func descubrirBotonesAdyacentes(coordenadas: Vector2) -> void:
	#Setting
	var listaCasillas : Array = container.get_children()
	var origen = listaCasillas[pasarDeDosDimensionesAUna(coordenadas)]
	var cantidadBombasAdyacentes : int = origen.cantidadBombasAdyacentes
	
	#verificacion cantidad de Banderas puestas
	var cantidadBanderas : int = 0
	var listaAdyacentes : Array = obtenerAdyacentes(coordenadas)
	for adyacente in listaAdyacentes:
		var casilla = listaCasillas[adyacente]
		if (casilla.tengoBandera):
			cantidadBanderas += 1
	
	#presionado final
	if (cantidadBanderas == cantidadBombasAdyacentes):
		for adyacente in listaAdyacentes:
			var casilla : CasillaNoActiva = listaCasillas[adyacente]
			casilla.casillaPresionada(false)
	verificarGameOver()

func desactivar_Botones() -> void:
	var listaCasillas = container.get_children()
	for x in range(columnas * filas):
		var casilla = listaCasillas[x]
		casilla.disabled = true

func pintarBombas() -> void:
	var listaCasillas : Array = container.get_children()
	for x in range (columnas * filas):
		var casilla : CasillaNoActiva = listaCasillas[x]
		if (casilla.esBomba()):
			casilla.pintarBombas()

func game_over() -> void:
	sonidoGameOver.play()
	partidaEnCurso = false
	pintarBombas()
	desactivar_Botones()
	panelGameOver.visible = true

func victoria() -> void:
	sonidoVictoria.play()
	partidaEnCurso = false
	desactivar_Botones()
	pintarBombas()
	animacion.play("victoria")
# ETC ==========================================================================

#Señales
func _on_iniciar_pressed() -> void:
	sonidoClick.play()
	animacion.play("dificultad")

func _on_salir_pressed() -> void:
	sonidoClick.play()
	get_tree().quit()

func _on_botoncito_pressed() -> void:
	sonidoClick.play()
	OS.window_fullscreen = !OS.window_fullscreen

func _on_Reiniciar_pressed() -> void:
	sonidoClick.play()
	if (primeraPartida): primeraPartida = false
	transicion.animar()

func _on_Salir_pressed() -> void:
	_on_salir_pressed()

func _on_bombita_terminoAnimacionDesaparicion() -> void:
	transicion.animar()
	visitados.clear()
	if (!display.visible):
		display.visible = true
	container = Cuadricula.instance()
	contenedorCuadricula.add_child(container)

#LLamada de reinicio de la partida
func _on_Transicion_mitadAnimacion() -> void:
	if (!primeraPartida):
		borrarGrilla()
		reiniciar()
		panelGameOver.visible = false
		panelDeVictoria.visible = false
	primerClick = true
	display.text = "¡A jugar!"
	configurarGrilla()
	bombita.visible = false
	panelDificultad.visible = false
	botonDificultad.visible = true
	tiempoLabel.visible = true
	tiempoLabel.asignarTexto(0, 0, 0)
	tiempoDePartida = 0

#Primera partida
func _on_AnimationPlayer_animation_finished(_anim_name) -> void:
	match _anim_name:
		"victoria":
			#Por ahora nada
			pass
		"iniciar":
			transicion.animar()
			visitados.clear()
			if (!display.visible):
				display.visible = true
			container = Cuadricula.instance()
			contenedorCuadricula.add_child(container)
			botones = $botones
			self.remove_child(botones)

func _on_PanelDeVictoria_reiniciar_presionado() -> void:
	SaveData.guardar(tiempoLabel.obtenerTiempo(), dificultad)
	_on_Reiniciar_pressed()

func _on_PanelDeVictoria_salir_presionado():
	_on_salir_pressed()

#DIFICULTAD

func _on_panelDificultad_dificilPresionado():
	dificultad = SaveData.DIFICIL
	columnas = 18
	filas = 13
	bombas = 46
	if (primeraPartida) :
		iniciar()
	else:
		transicion.animar()

func _on_panelDificultad_facilPresionado():
	dificultad = SaveData.FACIL
	columnas = CANTIDAD_COLUMMNAS
	filas = columnas
	bombas = CANTIDAD_BOMBAS
	if (primeraPartida) :
		iniciar()
	else:
		transicion.animar()

func _on_panelDificultad_intermedioPresionado():
	dificultad = SaveData.INTERMEDIO
	columnas = 12
	filas = 12
	bombas = 28
	if (primeraPartida) :
		iniciar()
	else:
		transicion.animar()

func _on_dificultadBoton_pressed():
	sonidoClick.play()
	primeraPartida = false
	partidaEnCurso = false
	animacion.play("dificultad")

func _on_panelDificultad_cerrarPresionado():
	sonidoClick.play()
	if not primerClick:
		partidaEnCurso = true
	animacion.play("dificultadDesaparecer")

#Opciones
func _on_opcionesBoton_pressed():
	partidaEnCurso = false
	sonidoClick.play()
	animacion.play("opcionesAparicion")

func _on_PanelConfiguracion_aceptarApretado():
	animacion.play("opcionesDesAparicion")
	if not primerClick:
		partidaEnCurso = true

func _on_PanelConfiguracion_salirApretado():
	animacion.play("opcionesDesAparicion")
	if not primerClick:
		partidaEnCurso = true

#Records
func _on_records_pressed():
	sonidoClick.play()
	GLOBAL.escenaAnterior = get_tree().current_scene.filename
	transicionDeEscena.transicionar("res://Objetos/Record.tscn")
