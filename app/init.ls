this.googleOnLoadCallback = ->
  this.GOOGLE_API_BROWSER_APPLICATION_KEY ?= ''
  gapi.client.setApiKey(this.GOOGLE_API_BROWSER_APPLICATION_KEY)
  gapi.client.load('youtube', 'v3', ->
    angular.element document .ready ->
      angular.bootstrap document, <[app]>
  )
