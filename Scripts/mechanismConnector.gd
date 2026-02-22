extends Node

@export var onlineMechanisms : Array

func deleteID(mechanismId : int):
	var id = onlineMechanisms.find(mechanismId,0)
	if id != -1: onlineMechanisms.remove_at(id)

func checkStatus(mechanismId : int) -> bool:
	var id = onlineMechanisms.find(mechanismId,0)
	if id == -1: return false
	else: return true
