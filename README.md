code-permissions
================

A code based permission system for Meteor apps.

If we have:

```coffee
@indicadores = new Meteor.Collection "indicadores"
@ACindicadores = new Meteor.Collection "ACindicadores"
```

where *indicador* is a normal collection with an extra field called *code*. And *ACindicadores* is its Access Control collection, that is like:

    code:
        type: String
    roles:
        type: [String]
    action:
        type: [String]
        allowedValues: ['insert', 'update', 'remove', 'fetch']

And given that Meteor.users has a roles field, then you can do things like:

```coffee
@Permission.register('indicador', @ACindicadores) # register the name 'indicador' with that AC collection.

@indicadores.allow
    insert: (userId, doc)->
        Permission.can.insert.indicador(userId, doc.code) # note that you use the name *indicador* that you have registered.
    update: (userId, doc, fieldNames, modifier) ->
        Permission.can.update.indicador(userId, doc.code)
    remove: (userId, doc) ->
        Permission.can.remove.indicador(userId, doc.code)

indicadores = @indicadores

Meteor.publish "indicadores", ->
    codes_allowed = Permission.can.fetch.indicador(@userId)
    indicadores.find({code: {$in: codes_allowed}})
```