AccessControl = new Meteor.Collection "AccessControl"

generate = (action, collection_name)->
    (userId, code) ->
        user_roles = Meteor.users.findOne({_id: userId}).roles
        can_roles = AccessControl.findOne({collection: collection_name, code: code, action: action}).roles
        if not _.isEmpty(_.intersection(user_roles, can_roles))
            true
        else
            false

generate_fetch = (collection_name) ->
    (userId) ->
        user_roles = Meteor.users.findOne({_id: userId}).roles
        x.code for x in AccessControl.find({collection: collection_name, action: 'fetch', roles: {$in: user_roles}}).fetch()
        

class @Permission
    @can: {update: {}, fetch: {}, insert: {}, remove: {}}
    @register:  (name, collection_name) ->
        Permission.can.insert[name] = generate('insert', collection_name)
        Permission.can.update[name] = generate('update', collection_name)
        Permission.can.fetch[name] = generate_fetch(collection_name)
        Permission.can.remove[name] = generate('remove', collection_name)

           

