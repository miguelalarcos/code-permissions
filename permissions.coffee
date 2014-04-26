AccessControl = new Meteor.Collection "AccessControl"

generate = (action, name)->
    (userId, code) ->
        user_roles = Meteor.users.findOne({_id: userId}).roles
        can_roles = AccessControl.findOne({collection: name, code: code, action: action}).roles
        if not _.isEmpty(_.intersection(user_roles, can_roles))
            true
        else
            false

generate_fetch = (name) ->
    (userId) ->
        user_roles = Meteor.users.findOne({_id: userId}).roles
        x.code for x in AccessControl.find({collection: name, action: 'fetch', roles: {$in: user_roles}}).fetch()
        

class @Permission
    @can: {update: {}, fetch: {}, insert: {}, remove: {}}
    @register:  (name) ->
        Permission.can.insert[name] = generate('insert', name)
        Permission.can.update[name] = generate('update', name)
        Permission.can.fetch[name] = generate_fetch(name)
        Permission.can.remove[name] = generate('remove', name)

           

