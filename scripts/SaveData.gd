extends Node

const directorio : String = "user://savedata.sav"

const FACIL = "facil"
const INTERMEDIO = "intermedio"
const DIFICIL = "dificil"

const MAX_JUGADORES = 14

var InputNombre = preload("res://Objetos/PanelNuevoRecord.tscn")
var inputNombre

class Ordenar:
	static func sort_ascending(a,b):
		if a[1] < b[1]:
			return true
		return false

var diccionario
var nombreDefault = "jugadorDebug"
var dificultadLista
var valor
var dificultad

func _ready():
	inputNombre = InputNombre.instance()
	inputNombre.connect("nombreValido", self, "agregarNombre")

func crearGameDataDefault():
	diccionario = {}
	
	diccionario[FACIL] = [["Ivancito", "001217"]]
	diccionario[INTERMEDIO] = [["Ivancito", "014356"]]
	diccionario[DIFICIL] = [["Ivancito", "023385"]]
	
	var savegame = File.new()
	savegame.open(directorio, File.WRITE)
	savegame.store_line(to_json(diccionario))
	savegame.close()

func cargar() -> Dictionary:
	var savegame = File.new()
	savegame.open(directorio,File.READ)
	if not savegame.file_exists(directorio) or savegame.get_line() == "":
		savegame.close()
		crearGameDataDefault()
	savegame.open(directorio, File.READ)
	diccionario = parse_json(savegame.get_line())
	savegame.close()
	return diccionario

func guardar(_valor : String, identificador : String) :
	diccionario = cargar()
	dificultadLista = diccionario[identificador]
	valor = _valor
	dificultad = identificador
	
	if dificultadLista.size() < MAX_JUGADORES or valor < dificultadLista.back()[1]:
		get_tree().current_scene.add_child(inputNombre)

#SEÑALES

func agregarNombre(nombre):
	get_tree().current_scene.remove_child(inputNombre)
	dificultadLista.append([nombre, valor])
	
	dificultadLista.sort_custom(Ordenar, "sort_ascending")
	
	if dificultadLista.size() > MAX_JUGADORES:
		dificultadLista.pop_back()
	
	diccionario[dificultad] = dificultadLista
	
	var savegame = File.new()
	savegame.open(directorio, File.WRITE)
	savegame.store_line(to_json(diccionario))
	savegame.close()
