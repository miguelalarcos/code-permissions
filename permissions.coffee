generate = (action, ACcollection)->
    (userId, code) ->
        user_roles = Meteor.users.findOne({_id: userId}).roles
        can_roles = ACcollection.findOne({code: code, action: action}).roles
        if not _.isEmpty(_.intersection(user_roles, can_roles))
            true
        else
            false

generate_fetch = (ACcollection) ->
    (userId) ->
        user_roles = Meteor.users.findOne({_id: userId}).roles
        x.code for x in ACcollection.find({action: 'fetch', roles: {$in: user_roles}}).fetch()
        

class @Permission
    @can: {update: {}, fetch: {}, insert: {}, remove: {}}
    @register:  (name, ACcollection) ->
        Permission.can.insert[name] = generate('insert', ACcollection)
        Permission.can.update[name] = generate('update', ACcollection)
        Permission.can.fetch[name] = generate_fetch(ACcollection)
        Permission.can.remove[name] = generate('remove', ACcollection)

           

