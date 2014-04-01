this.googleOnLoadCallback = ->
  gapi.client.setApiKey('AIzaSyDN3lT4KenTRpKGvoD1Cbw5yqMxR2iKBes')
  gapi.client.load('youtube', 'v3', ->
    angular.element document .ready ->
      angular.bootstrap document, <[app]>
  )
