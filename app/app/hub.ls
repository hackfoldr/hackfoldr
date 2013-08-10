angular.module 'hub.g0v.tw' <[ui.state firebase github]>
.config ($httpProvider) ->
    $httpProvider.defaults.useXDomain = true
    delete $httpProvider.defaults.headers.common['X-Requested-With']
.controller AuthzCtrl: <[$scope $window $state Hub]> ++ ($scope, $window, $state, Hub) ->
  $scope.$on 'event:auth-logout' -> $scope.safeApply $scope, ->
    $scope.cleanup?!
  $scope.$on 'event:auth-login' (e, {user}) -> $scope.$apply ->
    f-ref = Hub.root.child "following/#{user.username}"
    req-ref = Hub.root.child "authz/#{$state.params.request}"
    <- f-ref.once \value
    following = it.val!
    <- req-ref.once \value
    req = it.val!
    email = Hub.auth-user.email ? Hub.auth-user.emails?0
    err <- req-ref.update {user.avatar, user.username, following, email, displayName: user.displayName ? user.username }

    if err
        console.log err
    else
        $window.location.href = that + '/' + $state.params.request if req.uri

.controller TagControl: <[$scope $state $location Hub]> ++ ($scope, $state, $location, Hub) ->
  $scope.$watch '$state.params.tag' (tag) ->
    $scope.tag = tag
    $scope.loadDisqus tag
  $scope <<< do
    toggle_tag: (e) ->
      this_element = angular.element(e.srcElement)
      if (this_element.parent().next().css('display')=='none')
        this_element.parent().next().css('display', 'block')
      else
        this_element.parent().next().css('display', 'none')
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

.controller ProjectCtrl: <[$scope $state $location $http $timeout Hub angularFire]> ++ ($scope, $state, $location, $http, $timeout, Hub, angularFire) ->
    $scope.$on 'event:hub-ready' -> $timeout -> $scope.safeApply $scope, ->
      featured = [p for p in Hub.projects when p.thumbnail]
      $scope.featured = featured[Math.floor Math.random! * *]
    $scope <<< do
        avatarFor: (user) -> Hub.people.getByName user ?.avatar ? "http://avatars.io/github/#user"    
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
        addfromURL: ->
            repo = prompt "Enter github user/repo with g0v.json", ''
            url = "https://api.github.com/repos/#{repo}/contents/g0v.json"
            <- $http.get url .error -> console.log it
            .success
            res = JSON.parse Base64.decode it?content
            $scope.project <<< res
        newProject: ->
            $scope.opts.isnew = true
            $scope.opts.editMode = true
            if $scope.project
                $scope.cleanup?!
                delete $scope.project
                $state.transitionTo 'project', {}
            $scope.project = {}

        checkProject: (project, meta) ->
            leak = []
            $scope.opts.warning = null
            for value in meta
                console.log value
                unless project[value]
                    console.log "leak #{value}"
                    leak.push value 
            
            if leak.length > 0
                $scope.opts.warning = 'g0v.json 無法符合格式，缺少了 ' + leak.join(', ') + ' 關鍵字'

            return $scope.opts.warning

        saveNew: (project) ->
            
            console.log 'show all projects'
            console.log Hub.projects
            # exit this save function
            return $scope.opts.warning = 'Github 網址不可為空' unless project.github
            return $scope.opts.warning = 'Github 網址不符合格式' unless angular.element('.github-url').val().match(/^https:\/\/github.com\/.*[a-zA-Z\d]\/.*[a-zA-Z\d]/)
            # return $scope.opts.warning = 'Github 網址與其他專案重複' if [p for p in Hub.projects when p.url is project.github].length

            ghData = project.github.split('/')
            ghUser = ghData[3]
            ghProject = ghData[4]

            $http.get "https://api.github.com/repos/#ghUser/#ghProject/contents/"
            .success (data, status, headers, config)->

                flagG0v = false
                result = null

                for value in data
                    name = value.name
                    if name.toLowerCase().match 'g0v.json'
                        flagG0v = true
                        result = value

                return $scope.opts.warning = 'Github 專案底下請放入 g0v.json' unless flagG0v

                # adjust to raw url of github
                url = result.html_url.replace('github.com', 'raw.github.com')
                url = url.replace('/blob', '')

                queryUrl = 'http://query.yahooapis.com/v1/public/yql?q=select * from html where url="{{query}}"&format=json&diagnostics=true&callback=JSON_CALLBACK'
                queryUrl = queryUrl.replace('{{query}}', url)

                $http.jsonp queryUrl
                .success (data, status, headers, config)->

                    # this is already parse layer
                    console.log data
                    $scope.opts.isnew = false
                    try
                        result = JSON.parse(data.query.results.body.p)
                        project <<< result
                    catch
                        return $scope.opts.warning = 'g0v.json 無法符合格式，請參考...' unless flagG0v
                    
                    $scope.checkProject(project, [
                        'name'
                        'keywords'
                        'description'
                        'description_zh'
                        'homepage'
                    ])
                    if $scope.opts.warning
                        return $scope.opts.warning
                    # name have to fullfill in g0v.json 
                    Hub.root.child "projects/#{project.name}" .set project <<< { created_by: Hub.login-user.username }
                    $state.transitionTo 'project.detail', { projectName: project.name }

            # XXX use proper angular form validation
            # return false unless project.name
            # XXX warn
            # return false if [p for p in Hub.projects when p.name is project.name].length
            # $scope.opts.isnew = false
            # Hub.root.child "projects/#{project.name}" .set project <<< { created_by: Hub.login-user.username }
            # $state.transitionTo 'project.detail', { projectName: project.name }

    $scope.$watch '$state.params.projectName' (projectName) ->
        return unless projectName
        $scope.projectName = projectName
        $scope.opts.editMode = false
        $scope.cleanup?!
        promise = angularFire Hub.root.child("projects/#{projectName}"), $scope, 'project', {}
        cb <- promise.then
        $scope.cleanup = cb

.controller PeopleCtrl: <[$scope $state Hub angularFire]> ++ ($scope, $state, Hub, angularFire) ->

    $scope <<< do
        gotag: (tag) -> $scope.go "/tag/#{ encodeURIComponent tag }"
        togglePerson: (person) ->
            $scope.showPerson = if $scope.showPerson==person then null else person
        remove_tag: (person, tag) ->
            person.tags = [t for t in person.tags when t isnt tag]
        add_tag: (person, tag) ->
            person.tags ?= []
            newtag = tag ? $scope.newtag
            person.tags.push newtag unless newtag in person.tags
            $scope.newtag = '' unless tag
            return false
        follow_person: (id) ->
            $scope.following.push id unless id in $scope.following
            $scope.followlist[id] = 1
        unfollow_person: (id) ->
            $scope.following = [t for t in $scope.following when t isnt id]
            delete $scope.followlist[id]
        projects: Hub.projects
        filteredpeople: Hub.filteredpeople
        people: Hub.people
        auth: Hub.auth
        hub: Hub
        set-username: Hub.set-username
        login-and-merge: Hub.login-and-merge
        login-and-link: Hub.login-and-link
    $scope.$on 'event:auth-login' (e, {user}) -> $scope.safeApply $scope, ->
        $scope.toSetUsername = false
        promise = angularFire Hub.root.child("people/#{user.username}"), $scope, 'user', {}
        p2 = angularFire Hub.root.child("following/#{user.username}"), $scope, 'following', []
        $scope.$watch 'following' (val) ->
            $scope.followlist = {[u, true] for u in val ? []}

        p2.then (cb) ->
            #$rootScope.$broadcast 'event:auth-userloaded', {$scope.user, $socpe.following}
            if c = $scope.cleanup
                $scope.cleanup = ->
                    c!
                    cb!
        promise.then (cb) ->
            $scope.safeApply $scope
            if c = $scope.cleanup
                $scope.cleanup = ->
                    c!
                    cb!

    $scope.$on 'event:auth-logout' -> $scope.safeApply $scope, ->
        $scope.cleanup?!
        delete $scope.user
        $scope.toSetUsername = false
    $scope.$on 'event:auth-userNameRequired' (e, {existing, username}) -> $scope.safeApply $scope, ->
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
        $scope.$watch 'people' $scope.safeApply $scope, -> do-tagcloud
    $scope.$watch 'search' !->
        if $scope.search !== void
            $scope.filteredpeople = $scope.people
    if Hub.login-user
        $scope.$emit 'event:auth-login' user: Hub.login-user
.factory Hub: <[$http angularFireCollection $rootScope]> ++ ($http, angularFireCollection, $rootScope) ->
    url = window.global.config.FIREBASE
    self = {}
    myDataRef = new Firebase(url)
    init = ->
        $rootScope.$broadcast 'event:hub-ready'
        self.inited = true
    filteredpeople = angularFireCollection myDataRef.child("people").limit 50
    people = angularFireCollection myDataRef.child \people
    projects = angularFireCollection myDataRef.child(\projects), init
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
        merge-auth = new FirebaseSimpleLogin myDataRef, (error, user) ->
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

    self.auth = new FirebaseSimpleLogin myDataRef, (error, user) ->
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
        filteredpeople: filteredpeople
