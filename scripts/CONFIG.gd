extends Node

const directorio = "user://configuracion.cfg"
var configFile = ConfigFile.new()

func crearConfiguracionDefault():
	configFile.set_value("audio", "volumenMaestro", 0)
	configFile.save(directorio)

func guardarConfiguracion(value):
	configFile.set_value("audio", "volumenMaestro", value)
	configFile.save(directorio)

func cargarConfiguracion():
	var error = configFile.load("user://configuracion.cfg")
	
	if error != OK:
		crearConfiguracionDefault()
		return
	
	#Cargamos los datos
	AudioServer.set_bus_volume_db(0, configFile.get_value("audio", "volumenMaestro"))

func _ready():
	cargarConfiguracion()
