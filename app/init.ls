this.googleOnLoadCallback = ->
  gapi.client.setApiKey require('config.jsenv').GOOGLE_API_BROWSER_APPLICATION_KEY
  gapi.client.load('youtube', 'v3', ->
    angular.element document .ready ->
      angular.bootstrap document, <[app]>
  )
