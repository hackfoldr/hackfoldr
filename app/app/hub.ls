angular.module 'hub.g0v.tw' <[ui.state firebase]>

.controller TagControl: <[$scope $state $location Hub]> ++ ($scope, $state, $location, Hub) ->
  $scope.$watch '$state.params.tag' (tag) ->
    $scope.tag = tag
    $scope.loadDisqus tag
  $scope <<< do
    gotag: (tag) -> $scope.go "/tag/#{ encodeURIComponent tag }"
    projects: Hub.projects
    people: Hub.people
    loadDisqus: (tag) ->
        if $location.host! is 'localhost'
            return
            window.disqus_developer = 1;

        window.disqus_shortname = 'g0vhub'
        window.disqus_identifier = encodeURIComponent "tag-#tag"
        window.disqus_url = "http://hack.g0v.tw/tag/#tag"
        window.disqus_title = "g0v.tw 》 tag  》#tag"
        if typeof DISQUS isnt 'undefined'
          DISQUS.reset do
            reload: true
            config: ->
              this.page <<< window{disqus_title, disqus_identifier, disqus_url}
        oldDsq = document.getElementById('disqusCommentScript');
        if(oldDsq)
            (document.getElementsByTagName('head')[0] ||
            document.getElementsByTagName('body')[0]).removeChild(oldDsq)
        ``
        // http://docs.disqus.com/developers/universal/
        (function() {
          var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
          dsq.src = 'http://angularjs.disqus.com/embed.js';
          (document.getElementsByTagName('head')[0] ||
            document.getElementsByTagName('body')[0]).appendChild(dsq);
        })();
        ``

        angular.element document.getElementById 'disqus_thread' .html ''

.controller ProjectCtrl: <[$scope $state $location Hub angularFire]> ++ ($scope, $state, $location, Hub, angularFire) ->
    $scope <<< do
        people: Hub.people
        projects: Hub.projects
        opts: {}
        remove_tag: (thing, tag) ->
            thing.keywords = [t for t in thing.keywords when t isnt tag]
        add_tag: (thing) ->
            thing.keywords ?= []
            thing.keywords.push $scope.opts.newtag unless $scope.opts.newtag in thing.keywords
            $scope.opts.newtag = ''
            return false
        newProject: ->
            $scope.opts.isnew = true
            $scope.opts.editMode = true
            if $scope.project
                $scope.cleanup?!
                delete $scope.project
                $state.transitionTo 'project', {}
            $scope.project = {}
        saveNew: (project) ->
            # XXX use proper angular form validation
            return false unless project.name
            return false if [p for p in Hub.projects when p.name is project.name].length
            $scope.opts.isnew = false
            Hub.root.child "projects/#{project.name}" .set project <<< { created_by: Hub.login-user.username }
            $state.transitionTo 'project.detail', { projectName: project.name }

    $scope.$watch '$state.params.projectName' (projectName) ->
        return unless projectName
        $scope.projectName = projectName
        $scope.opts.editMode = false
        $scope.cleanup?!
        promise = angularFire Hub.root.child("projects/#{projectName}"), $scope, 'project', {}
        cb <- promise.then
        $scope.cleanup = cb

.controller PeopleCtrl: <[$scope $state Hub angularFire]> ++ ($scope, $state, Hub, angularFire) ->
    $scope.safeApply = (fn) ->
        phase = $scope.$root.$$phase
        if (phase is '$apply' || phase is '$digest')
            fn?!
        else
            $scope.$apply fn

    $scope <<< do
        gotag: (tag) -> $scope.go "/tag/#{ encodeURIComponent tag }"
        remove_tag: (person, tag) ->
            person.tags = [t for t in person.tags when t isnt tag]
        add_tag: (person, tag) ->
            person.tags ?= []
            newtag = tag ? $scope.newtag
            person.tags.push newtag unless newtag in person.tags
            $scope.newtag = '' unless tag
            return false
        projects: Hub.projects
        people: Hub.people
        auth: Hub.auth
        hub: Hub
        set-username: Hub.set-username
        login-and-merge: Hub.login-and-merge
        login-and-link: Hub.login-and-link
    $scope.$on 'event:auth-login' (e, {user}) -> $scope.safeApply ->
        $scope.toSetUsername = false
        promise = angularFire Hub.root.child("people/#{user.username}"), $scope, 'user', {}
        cb <- promise.then
        $scope.safeApply!
        $scope.cleanup = cb
    $scope.$on 'event:auth-logout' -> $scope.safeApply ->
        $scope.cleanup?!
        delete $scope.user
        $scope.toSetUsername = false
    $scope.$on 'event:auth-userNameRequired' (e, {existing, username}) -> $scope.safeApply ->
        $scope.toSetUsername = true
        $scope.usernameInUse = existing
        $scope.newUsername = username

    $scope.$watch 'hub.inited' ->
        return unless it
        do-tagcloud = (people) ->
            return unless people
            tagcloud = {}
            for _, {tags}:p of people when tags
                for tag in tags
                    tagcloud[tag] ?= 0
                    tagcloud[tag]++
            $scope.tagcloud = [{tag, count} for tag, count of tagcloud when count > 1].sort (a, b) -> b.count - a.count
        do-tagcloud $scope.people if Hub.people.length
        <- setTimeout _, 100ms
        $scope.$watch 'people' $scope.safeApply -> do-tagcloud
    if Hub.login-user
        $scope.$emit 'event:auth-login' user: Hub.login-user

.factory Hub: <[$http angularFireCollection $rootScope]> ++ ($http, angularFireCollection, $rootScope) ->
    url = window.global.config.FIREBASE
    self = {}
    myDataRef = new Firebase(url)
    init = ->
        self.inited = true
    people = angularFireCollection myDataRef.child(\people), init
    projects = angularFireCollection myDataRef.child \projects
    check-username = (username, always-prompt, cb) ->
        username.=replace(/\./g, \,)
        inuse <- myDataRef.child "people/#{username}" .once \value
        existing = inuse.val!
        if always-prompt || existing
            $rootScope.$broadcast 'event:auth-userNameRequired', {existing, username}
        cb?! unless existing

    self.set-username = (username) ->
        return unless self.auth-user
        <- check-username username, false
        # XXX: disallow if people/#username exists and we do not have the credentials listed in auth
        info = {tags: [], username}
        info.auth = "#{self.auth-user.provider}": self.auth-user{id, username ? ''}
        info.displayName = self.auth-user.displayName if self.auth-user.displayName
        info.avatar = match self.auth-user.provider
        | 'github'
            [_, gravatar] = self.auth-user.avatar_url.match // https:\/\/secure.gravatar.com/avatar/(\w+) //
            "http://avatars.io/gravatar/#gravatar"
        | 'twitter'
            "http://avatars.io/twitter/#{self.auth-user.username}"
        | 'persona'
            "http://avatars.io/gravatar/#{self.auth-user.hash}"
        else
            "http://avatars.io/#{self.auth-user.provider}/#{self.auth-user.id}"
        myDataRef
            ..child "auth-map/#{self.auth-user.provider}/#{self.auth-user.id}" .set {username}
            ..child "people/#{username}" .set info
        login-user <- myDataRef.child "people/#{username}" .once \value
        self.login-user = login-user.val!
        $rootScope.$broadcast 'event:auth-login', user: self.login-user

    self.login-and-merge = (provider) ->
        done = (username) ->
            # here we use the current token, which allows to write to people/#username
            user = self.auth-user
            entry = myDataRef.child "people/#{username}/auth" .update "#{user.provider}": user{id, username ? ''}
            # now we switch back to the previous token, which authenticates as the new provider to be merged
            err <- myDataRef.auth user.firebaseAuthToken
            myDataRef.child "auth-map/#{user.provider}/#{user.id}" .set {username}
            $rootScope.$broadcast 'event:auth-login', user: self.login-user
        merge-auth = new FirebaseAuthClient myDataRef, (error, user) ->
            if error => console.log error
            if user
                auth <- myDataRef.child "auth-map/#{user.provider}/#{user.id}" .once \value
                if {username}? = auth.val!
                    done username
        merge-auth.login provider

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
            if !self.auth-link and {username}? = auth.val!
                entry = myDataRef.child "people/#{username}"
                login-user <- entry.once \value
                self.login-user = login-user.val!
                unless self.login-user
                    return check-username username, true
                $rootScope.$broadcast 'event:auth-login', user: self.login-user
            else
                if link = self.auth-link
                    username = self.auth-link-user.username
                    myDataRef.child "auth-map/#{user.provider}/#{user.id}" .set {username}
                    err <- myDataRef.auth link.firebaseAuthToken
                    myDataRef.child "people/#{username}/auth" .update "#{user.provider}": user{id, username ? ''}
                    delete self.auth-link
                else
                    self.auth-user.username ?= self.auth-user.email?split(\@)?0
                    check-username self.auth-user.username, true
        else
            $rootScope.$broadcast 'event:auth-logout'
    self <<< do
        root: myDataRef
        people: people
        projects: projects
