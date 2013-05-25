angular.module 'hub.g0v.tw' <[ui.state]>

.controller TagControl: <[$scope $state]> ++ ($scope, $state) ->
  $scope.$watch '$state.params.tag' (tag) ->
    $scope.tag = tag
  $scope <<< do
    projects:
      * name: \立法院
      * name: \meta
    people:
      * name: \clkao
        github: \clkao
        twitter: \clkao
        tags: <[ly g0v hackath3n livescript]>
        status: \available
      * name: \hlb
        github: \hlb
        twitter: \hlb
        tags: <[design]>
        status: \available
      ...

.controller PeopleCtrl: <[$scope $state]> ++ ($scope, $state) ->
  $scope <<< do
    add_tag: (person, tag) ->
      person.tags.push tag
      return false
    user: do
      name: \clkao
      github: \clkao
      twitter: \clkao
      tags: <[ly g0v hackath3n livescript]>
      status: \available

    projects:
      * name: \立法院
      * name: \meta
    people:
      * name: \clkao
        github: \clkao
        twitter: \clkao
        tags: <[ly g0v hackath3n livescript]>
        status: \available
      * name: \hlb
        github: \hlb
        twitter: \hlb
        tags: <[design]>
        status: \available
      ...
