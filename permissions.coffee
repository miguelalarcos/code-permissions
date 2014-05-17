AccessControl = new Meteor.Collection "AccessControl",
    schema:
        name: 
            type: String
        _code:
            type: String
        roles:
            type: [String]
        action:
            type: [String]
            allowedValues: ['insert', 'update', 'remove', 'fetch']

generate = (action, name)->
    (userId, _code) ->
        user_roles = Meteor.users.findOne({_id: userId}).roles
        can_roles = AccessControl.findOne({name: name, _code: _code, action: action}).roles
        if not _.isEmpty(_.intersection(user_roles, can_roles))
            true
        else
            false

generate_fetch = (name) ->
    (userId) ->
        user_roles = Meteor.users.findOne({_id: userId}).roles
        x._code for x in AccessControl.find({name: name, action: 'fetch', roles: {$in: user_roles}}).fetch()
        
generate_grant = (name, action) ->(_code, roles) ->
        p = AccessControl.findOne {name: name, _code: _code, action: action}
        if p
            AccessControl.update {name: name, _code: _code, action: action}, {$addToSet: {roles: {$each: roles}}}
        else
            AccessControl.insert {name: name, _code: _code, roles: roles, action: action}

generate_revoke = (name, action) -> (_code, roles) ->
        AccessControl.update {name: name, _code: _code, action: action}, {$pullAll: {roles: roles}}

class Permission
    @can: {update: {}, fetch: {}, insert: {}, remove: {}}
    @grant: {update: {}, fetch: {}, insert: {}, remove: {}}
    @revoke: {update: {}, fetch: {}, insert: {}, remove: {}}

    @register:  (name) ->
        Permission.can.insert[name] = generate('insert', name)
        Permission.can.update[name] = generate('update', name)
        Permission.can.fetch[name] = generate_fetch(name)
        Permission.can.remove[name] = generate('remove', name)
        for action in ['update','fetch','insert','remove']
            Permission.grant[action][name] = generate_grant(name, action)
            Permission.revoke[action][name] = generate_revoke(name, action)

    @protect: (collection, name) ->
        Permission.register name
        collection.allow
            insert : (userId, doc) ->
                Permission.can.insert[name] userId, doc._code
            update: (userId, doc, fieldNames, modifier) ->
                Permission.can.update[name] userId, doc._code
            remove : (userId, doc) ->
                Permission.can.remove[name] userId, doc._code
    



           

