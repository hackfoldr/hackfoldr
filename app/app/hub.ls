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
  Hub.register!
  promise = angularFire Hub.root.child('people/clkao'), $scope, 'user', {}
  $scope <<< do
    add_tag: (person, tag) ->
      person.tags.push tag
      return false
    user: Hub.user
    projects:
      * name: \立法院
      * name: \meta
    people: Hub.people

.factory Hub: <[$http angularFireCollection]> ++ ($http, angularFireCollection) ->
    url = window.global.config.FIREBASE
    myDataRef = new Firebase(url)
    people = angularFireCollection myDataRef.child \people
    user = angularFireCollection myDataRef.child \people/clkao
    self = do
        root: myDataRef
        people: people
        user: user
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
