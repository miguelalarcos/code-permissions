AccessControl = new Meteor.Collection "AccessControl"

generate = (action, name)->
    (userId, code) ->
        user_roles = Meteor.users.findOne({_id: userId}).roles
        can_roles = AccessControl.findOne({name: name, code: code, action: action}).roles
        if not _.isEmpty(_.intersection(user_roles, can_roles))
            true
        else
            false

generate_fetch = (name) ->
    (userId) ->
        user_roles = Meteor.users.findOne({_id: userId}).roles
        x.code for x in AccessControl.find({name: name, action: 'fetch', roles: {$in: user_roles}}).fetch()
        

class Permission
    @can: {update: {}, fetch: {}, insert: {}, remove: {}}
    @register:  (name) ->
        Permission.can.insert[name] = generate('insert', name)
        Permission.can.update[name] = generate('update', name)
        Permission.can.fetch[name] = generate_fetch(name)
        Permission.can.remove[name] = generate('remove', name)
    @protect: (collection, name) ->
        Permission.register name
        collection.allow
            insert : (userId, doc) ->
                Permission.can.insert[name] userId, doc.code
            update: (userId, doc, fieldNames, modifier) ->
                Permission.can.update[name] userId, doc.code
            remove : (userId, doc) ->
                Permission.can.remove[name] userId, doc.code
    @grant: (name, code, roles, action) ->
        p = AccessControl.findOne {name: name, code: code, action: action}
        if p
            AccessControl.update {name: name, code: code, action: action}, {$addToSet: {roles: {$each: roles}}}
        else
            AccessControl.insert {name: name, code: code, roles: roles, action: action}

    @revoke: (name, code, roles, action) ->
        AccessControl.update {name: name, code: code, action: action}, {$pullAll: {roles: roles}}



           

