angular.module 'hub.g0v.tw' <[ui.state firebase]>

.controller TagControl: <[$scope $state Hub]> ++ ($scope, $state, Hub) ->
  $scope.$watch '$state.params.tag' (tag) ->
    $scope.tag = tag
  $scope <<< do
    projects:
      * name: \立法院
      * name: \meta
    people: Hub.people

.controller PeopleCtrl: <[$scope $state Hub angularFire]> ++ ($scope, $state, Hub, angularFire) ->
    $scope.safeApply = (fn) ->
        phase = $scope.$root.$$phase
        if (phase is '$apply' || phase is '$digest')
            fn?!
        else
            $scope.$apply fn

    $scope <<< do
        avatar: (user, version = 'medium') ->
            | user.auth?github?username
                "http://avatars.io/github/#{user.auth.github.username}?size=#version"
            | user.auth?twitter?username
                "http://avatars.io/github/#{user.auth.twitter.username}?size=#version"
            | user.auth?github?username
                "http://avatars.io/github/#{user.auth.github.username}?size=#version"
        add_tag: (person) ->
            person.tags ?= []
            # XXX check duplicated
            person.tags.push $scope.newtag
            $scope.newtag = ''
            return false
        projects:
          * name: \立法院
          * name: \meta
        people: Hub.people
        auth: Hub.auth
        set-username: Hub.set-username
        login-and-merge: Hub.login-and-merge
        login-and-link: Hub.login-and-link
    $scope.$on 'event:auth-login' (e, {user}) -> $scope.safeApply ->
        promise = angularFire Hub.root.child("people/#{user.username}"), $scope, 'user', {}
        $scope.toSetUsername = false
    $scope.$on 'event:auth-logout' -> $scope.safeApply ->
        delete $scope.user
        $scope.toSetUsername = false
    $scope.$on 'event:auth-userNameRequired' (e, {existing}) -> $scope.safeApply ->
        $scope.toSetUsername = true
        $scope.usernameInUse = existing
        $scope.newUsername = Hub.auth-user?username

.factory Hub: <[$http angularFireCollection $rootScope]> ++ ($http, angularFireCollection, $rootScope) ->
    url = window.global.config.FIREBASE
    myDataRef = new Firebase(url)
    people = angularFireCollection myDataRef.child \people
    self = {}
    check-username = (username, always-prompt, cb) ->
        inuse <- myDataRef.child "people/#{username}" .once \value
        existing = inuse.val!
        if always-prompt || existing
            $rootScope.$broadcast 'event:auth-userNameRequired', {existing}
        cb?! unless existing

    self.set-username = (username) ->
        return unless self.auth-user
        <- check-username username, false
        # XXX: disallow if people/#username exists and we do not have the credentials listed in auth
        myDataRef
            ..child "auth-map/#{self.auth-user.provider}/#{self.auth-user.id}" .set {username}
            ..child "people/#{username}" .set self.auth-user{displayName} <<< {tags: [], username}
            ..child "people/#{username}/auth/#{self.auth-user.provider}" .set self.auth-user{id, username}
        login-user <- myDataRef.child "people/#{username}" .once \value
        self.login-user = login-user.val!
        $rootScope.$broadcast 'event:auth-login', user: self.login-user

    self.login-and-merge = (provider) ->
        self.auth-merge = self.auth-user
        self.auth.login provider
    self.login-and-link = (provider) ->
        self.auth-link = self.auth-user
        self.auth-link-user = self.login-user
        self.auth.login provider
    self.auth = new FirebaseAuthClient myDataRef, (error, user) ->
        if error
            console.log error
        else if user
            self.auth-user = user
            auth <- myDataRef.child "auth-map/#{user.provider}/#{user.id}" .once \value
            if {username}? = auth.val!
                entry = myDataRef.child "people/#{username}"
                login-user <- entry.once \value
                if merge = self.auth-merge
                    newauth = { "#{merge.provider}": merge{id, username ? ''} }
                    entry.child 'auth' .update newauth
                    myDataRef.child "auth-map/#{merge.provider}/#{merge.id}" .set {username}
                    delete self.auth-merge
                self.login-user = login-user.val!
                $rootScope.$broadcast 'event:auth-login', user: self.login-user
            else
                if link = self.auth-link
                    username = self.auth-link-user.username
                    # XXX might need to reuse the token from self.auth-link to write
                    entry = myDataRef.child "people/#{username}"
                    #login-user <- entry.once \value
                    #self.login-user = login-user.val!
                    newauth = { "#{user.provider}": user{id, username ? ''} }
                    #$rootScope.$broadcast 'event:auth-login', user: self.login-user
                    entry.child 'auth' .update newauth
                    myDataRef.child "auth-map/#{user.provider}/#{user.id}" .set {username}
                    delete self.auth-link
                else
                    check-username self.auth-user.username, true
        else
            $rootScope.$broadcast 'event:auth-logout'
    self <<< do
        root: myDataRef
        people: people
        register: ->
            person = do
              name: \clkao
              github: \clkao
              twitter: \clkao
              tags: <[ly g0v hackath3n livescript]>
              status: \available
            user = myDataRef.child "people/#{person.name}"
            me <- user.once \value
            unless me.val!
                user.set person
