extends TextureRect

onready var animationPlayer : AnimationPlayer = $AnimationPlayer

var desaparecida : bool = false

signal terminoAnimacionDesaparicion

func _ready():
	animationPlayer.play("idle")

func aparecer() -> void:
	animationPlayer.play("aparecer")

func desaparecer() -> void:
	animationPlayer.play("desaparecer")
	desaparecida = true
	
func estaDesaparecida() -> bool:
	return desaparecida

func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "desaparecer"):
		visible = false
		emit_signal("terminoAnimacionDesaparicion")
