extends Reference

class_name User

var user_id: String
var username: String
var email: String
var password_hash: String
var consent_flags := {}
var created_at: String
var last_login: String

func _init():
    user_id = ""
    username = ""
    email = ""
    password_hash = ""
    created_at = ""
    last_login = ""
