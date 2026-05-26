extends Node

class_name AppContainer

var user_repository
var visit_repository
var profile_repository
var group_repository
var consent_policy

func _ready():
    # Composition root: instantiate default implementations or stubs
    print("AppContainer ready. Wire dependencies here.")
