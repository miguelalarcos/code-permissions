Package.describe({
    summary: "A code based permission system for Meteor apps"
});

Package.on_use(function (api) {
    api.use(['coffeescript', 'underscore'], 'server');

    api.add_files('permissions.coffee', 'server');
});