code-permissions
================

A code based permission system for Meteor apps.

I have been working for 6 years in a software for hospitals, and found the necessity of a code based permission system. I give you an example: for the same collection *Notes*, you have nurse notes, doctor notes, surgery notes and so on. They are different kind of notes, and a *code* field is used to differentiate them: 'NURSE', 'DOCTOR', 'SURGERY' can be the codes.

If we have:

```coffee
@indicators = new Meteor.Collection "Clinic Indicators"
```

where *indicators* is a normal collection with an extra field called *code*.

And given that Meteor.users has a *roles* field, then you can do things like:

```coffee
Permission.register('indicator') # register the name 'indicator'

@indicators.allow
    insert: (userId, doc)->
        Permission.can.insert.indicator(userId, doc._code) # note that you use the name indicator that you have registered.
    update: (userId, doc, fieldNames, modifier) ->
        Permission.can.update.indicator(userId, doc._code)
    remove: (userId, doc) ->
        Permission.can.remove.indicator(userId, doc._code)

#or simply
Permission.protect indicators, 'indicator' # you protect the collection indicators with the name indicator

indicators = @indicators

Meteor.publish "indicators", ->
    codes_allowed = Permission.can.fetch.indicator(@userId) # note that you use the name indicator
    indicators.find({_code: {$in: codes_allowed}})

Permission.grant 'indicator', 'ESP', ['doctor', 'nurse'], 'insert' # note you use the name indicator
Permission.revoke 'indicator', 'ESP', ['nurse'], 'insert'    
```

There is a special and private collection called AccessControl, that is like:

```
    name: 
        type: String
    _code:
        type: String
    roles:
        type: [String]
    action:
        type: [String]
        allowedValues: ['insert', 'update', 'remove', 'fetch']
```

and you can have a register like this one:

```
    name: 'indicator',
    _code: 'ESP',
    roles: ['doctor'],
    action: 'fetch'
```

which means that if an user has the role 'doctor', then he can fetch all registers with the code ESP in the collection 'indicators' (remember you are using the name 'indicator' with the collection 'indicators').


