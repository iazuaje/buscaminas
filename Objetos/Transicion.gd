extends Control


signal mitadAnimacion

func animar() -> void :
	visible = true
	$AnimationPlayer.play("transicion")

func _on_AnimationPlayer_animation_finished(_anim_name):
	visible = false

func emitirSenial():
	emit_signal("mitadAnimacion")
