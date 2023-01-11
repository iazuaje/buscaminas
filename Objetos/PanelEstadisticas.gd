extends ColorRect

onready var cabezera = $CabezeraLabel
onready var contenedorData = $ContenedorData

var identificador : String

func setNombre(nombre : String, _identificador : String):
	cabezera.text = nombre
	identificador = _identificador

func setData(lista : Array):
	var data : Array = contenedorData.get_children()
	#var cantidadData = contenedorData.get_child_count()
	var contador : int = 0
	for dato in lista:
		data[contador].text = dato[0] + "  =  " + limpiarTiempo(dato[1])
		contador += 1

func limpiarTiempo(tiempo : String):
	var nuevoTiempo : String = ""
	var contador : int = 0
	var iteracion : int = 0
	for letra in tiempo:
		nuevoTiempo = nuevoTiempo.insert(iteracion, letra)
		contador += 1
		iteracion += 1
		if contador % 2 == 0 and contador != 6:
			nuevoTiempo = nuevoTiempo.insert(iteracion, ":")
			iteracion += 1
	return nuevoTiempo
