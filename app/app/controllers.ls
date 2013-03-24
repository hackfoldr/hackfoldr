angular.module 'app.controllers' []
.controller AppCtrl: <[$scope $location $resource $rootScope]> ++ (s, $location, $resource, $rootScope) ->

  s <<< {$location}
  s.$watch '$location.path()' (activeNavId or '/') ->
    s <<< {activeNavId}

  s.getClass = (id) ->
    if s.activeNavId.substring 0 id.length is id
      'active'
    else
      ''
.controller HackFolder: <[$scope]> ++ ($scope) ->
    $scope.sortableOptions = do
        update: -> console.log \updated

    $scope.docs =
        * type: \gdoc
          id: '1_7j4epy9S9f0-EHifVsy8tWv-tTGlkDSjjmWDfqrl1s'
          name: \README
        * type: \hackpad
          id: 'BfddbG2JBOi'
          name: \ly-api
        * type: \gdoc
          id: '12a_zHq_ooEv_9R2o3awIaBbDfzl89WB1COSPjVlQwGM'
          name: \場地資訊

    $scope.iframes = {}
    $scope.debug = (element) ->
        console.log @, $scope, element
    $scope.activate = ({type,id}:doc, edit=false) ->
        mode = if edit => \edit else \view
        src = match type
        | \gdoc =>
            "https://docs.google.com/document/d/#id/#mode"
        | \hackpad =>
            "https://hackpad.com/#id"

        if $scope.iframes[id]
            that <<< {src, mode}
        else
            $scope.iframes[id] = {src, doc, mode}
        $scope.currentIframe = id

.directive 'resize' <[$window]> ++ ($window) ->
  (scope) ->
    scope.width = $window.innerWidth
    scope.height = $window.innerHeight
    angular.element $window .bind 'resize' ->
      scope.$apply ->
        scope.width = $window.innerWidth
        scope.height = $window.innerHeight
