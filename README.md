code-permissions
================

A code based permission system for Meteor apps.

If we have:

```coffee
@indicadores = new Meteor.Collection "indicadores"
```

where *indicadores* is a normal collection with an extra field called *code*.

And given that Meteor.users has a *roles* field, then you can do things like:

```coffee
@Permission.register('indicador') # register the name 'indicador'

@indicadores.allow
    insert: (userId, doc)->
        Permission.can.insert.indicador(userId, doc.code) # note that you use the name indicador that you have registered.
    update: (userId, doc, fieldNames, modifier) ->
        Permission.can.update.indicador(userId, doc.code)
    remove: (userId, doc) ->
        Permission.can.remove.indicador(userId, doc.code)

indicadores = @indicadores

Meteor.publish "indicadores", ->
    codes_allowed = Permission.can.fetch.indicador(@userId)
    indicadores.find({code: {$in: codes_allowed}})
```

There is a special collection called AccessControl, that is like:

```
    name: 
        type: String
    code:
        type: String
    roles:
        type: [String]
    action:
        type: [String]
        allowedValues: ['insert', 'update', 'remove', 'fetch']
```

and you can have a register like this one:

```
    name: 'indicador',
    code: 'ESP',
    roles: ['medico'],
    action: 'fetch'
```

which means that if an user has the role 'medico', then he can fetch all registers with the code ESP in the collection 'indicadores' (remember you are using the name 'indicador' with the collection 'indicadores').


