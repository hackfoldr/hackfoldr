angular.module 'irc.g0v.tw' <[ui.state]>
.controller IRC: ($scope, $state) ->
  $scope.$watch '$state.current.name' ->
    switch it
    | \irc => $scope.irc-enabled = true
    | \irc.log => $scope.irclog-enabled = true
    $scope.irc-active = $state.includes \irc

