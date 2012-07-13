$ ->
	### User Model ###

	class User extends Backbone.Model

		# Defaults
		defaults:
			username: "anon"
			password: ""

		# Init
		initialize:
			if !@get("username")
				@set({"username": @defaults.username})
			if !@get("pass")
				@set({"username": @defaults.password})

		# Remove a user
		remove:
			@destroy()
			@view.remove()

	### Users Collection ###

	class Users extends Backbone.Collection

		model: User

		getPass: (user) ->
			return user.get("password")

		comparator: (user) ->
			return user.get("username")

	### UserView View ###

	class LoginView extends Backbone.View

	











