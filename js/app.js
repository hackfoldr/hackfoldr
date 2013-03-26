(function(/*! Brunch !*/) {
  'use strict';

  var globals = typeof window !== 'undefined' ? window : global;
  if (typeof globals.require === 'function') return;

  var modules = {};
  var cache = {};

  var has = function(object, name) {
    return ({}).hasOwnProperty.call(object, name);
  };

  var expand = function(root, name) {
    var results = [], parts, part;
    if (/^\.\.?(\/|$)/.test(name)) {
      parts = [root, name].join('/').split('/');
    } else {
      parts = name.split('/');
    }
    for (var i = 0, length = parts.length; i < length; i++) {
      part = parts[i];
      if (part === '..') {
        results.pop();
      } else if (part !== '.' && part !== '') {
        results.push(part);
      }
    }
    return results.join('/');
  };

  var dirname = function(path) {
    return path.split('/').slice(0, -1).join('/');
  };

  var localRequire = function(path) {
    return function(name) {
      var dir = dirname(path);
      var absolute = expand(dir, name);
      return globals.require(absolute);
    };
  };

  var initModule = function(name, definition) {
    var module = {id: name, exports: {}};
    definition(module.exports, localRequire(name), module);
    var exports = cache[name] = module.exports;
    return exports;
  };

  var require = function(name) {
    var path = expand(name, '.');

    if (has(cache, path)) return cache[path];
    if (has(modules, path)) return initModule(path, modules[path]);

    var dirIndex = expand(path, './index');
    if (has(cache, dirIndex)) return cache[dirIndex];
    if (has(modules, dirIndex)) return initModule(dirIndex, modules[dirIndex]);

    throw new Error('Cannot find module "' + name + '"');
  };

  var define = function(bundle) {
    for (var key in bundle) {
      if (has(bundle, key)) {
        modules[key] = bundle[key];
      }
    }
  }

  globals.require = require;
  globals.require.define = define;
  globals.require.brunch = true;
})();

(function() {
  var App;
angular.module('scroll', []).value('$anchorScroll', angular.noop);
App = angular.module('app', ['ui', 'ngCookies', 'ngResource', 'app.controllers', 'scroll']);
App.config(['$routeProvider', '$locationProvider'].concat(function($routeProvider, $locationProvider, config){
  $routeProvider.when('/:hackId', {
    templateUrl: '/partials/app/hack.html'
  }).when('/:hackId/:docId', {
    templateUrl: '/partials/app/hack.html'
  }).when('/about', {
    templateUrl: '/partials/app/about.html'
  }).otherwise({
    redirectTo: '/'
  });
  return $locationProvider.html5Mode(false);
}));
window.App = App;
}).call(this);

(function() {
  var slice$ = [].slice, replace$ = ''.replace;
angular.module('app.controllers', []).controller({
  AppCtrl: ['$scope', '$location', '$resource', '$rootScope'].concat(function(s, $location, $resource, $rootScope){
    s.$location = $location;
    s.$watch('$location.path()', function(activeNavId){
      activeNavId || (activeNavId = '/');
      return s.activeNavId = activeNavId, s;
    });
    return s.getClass = function(id){
      if (s.activeNavId.substring(0, id.length === id)) {
        return 'active';
      } else {
        return '';
      }
    };
  })
}).controller({
  HackFolderCtrl: ['$scope', '$routeParams', 'HackFolder'].concat(function($scope, $routeParams, HackFolder){
    var that;
    if (typeof console != 'undefined' && console !== null) {
      console.log($routeParams);
    }
    import$($scope, {
      hasViewMode: function(it){
        return it.match(/g(doc|present|draw)/);
      },
      sortableOptions: {
        update: function(){
          return typeof console != 'undefined' && console !== null ? console.log('notyetupdated') : void 8;
        }
      },
      iframes: HackFolder.iframes,
      docs: HackFolder.docs,
      activate: HackFolder.activate,
      reload: function(hackId){
        return HackFolder.getIndex(hackId, true, function(){});
      }
    });
    $scope.$watch('hackId', function(hackId){
      return HackFolder.getIndex(hackId, false, function(){
        return $scope.$watch('docId', function(docId){
          return HackFolder.activate(docId);
        });
      });
    });
    $scope.hackId = (that = $routeParams.hackId) ? that : 's8r4l008sk';
    if ($routeParams.docId) {
      return $scope.docId = encodeURIComponent($routeParams.docId);
    }
  })
}).directive('resize', ['$window'].concat(function($window){
  return function(scope){
    scope.width = $window.innerWidth;
    scope.height = $window.innerHeight;
    return angular.element($window).bind('resize', function(){
      return scope.$apply(function(){
        scope.width = $window.innerWidth;
        return scope.height = $window.innerHeight;
      });
    });
  };
})).factory({
  HackFolder: ['$http'].concat(function($http){
    var iframes, docs, hackId;
    iframes = {};
    docs = [];
    return {
      iframes: iframes,
      docs: docs,
      activate: function(id, edit){
        var d, doc, type, mode, src, that;
        edit == null && (edit = false);
        doc = (function(){
          var i$, ref$, len$, results$ = [];
          for (i$ = 0, len$ = (ref$ = docs).length; i$ < len$; ++i$) {
            d = ref$[i$];
            if (d.id === id) {
              results$.push(d);
            }
          }
          return results$;
        }())[0], type = doc.type;
        mode = edit ? 'edit' : 'view';
        src = (function(){
          var ref$;
          switch (ref$ = [type], false) {
          case 'gdoc' !== ref$[0]:
            return "https://docs.google.com/document/d/" + id + "/" + mode;
          case 'gsheet' !== ref$[0]:
            return "https://docs.google.com/spreadsheet/ccc?key=" + id;
          case 'gpresent' !== ref$[0]:
            return "https://docs.google.com/presentation/d/" + id + "/" + mode;
          case 'gdraw' !== ref$[0]:
            return "https://docs.google.com/drawings/d/" + id + "/" + mode;
          case 'gsheet' !== ref$[0]:
            return "https://docs.google.com/spreadsheet/ccc?key=" + id;
          case 'hackpad' !== ref$[0]:
            return "https://hackpad.com/" + id;
          case 'ethercalc' !== ref$[0]:
            return "http://ethercalc.com/" + id;
          case 'url' !== ref$[0]:
            return decodeURIComponent(decodeURIComponent(id));
          }
        }());
        if (that = iframes[id]) {
          return that.src = src, that.mode = mode, that;
        } else {
          return iframes[id] = {
            src: src,
            doc: doc,
            mode: mode
          };
        }
      },
      getIndex: function(id, force, cb){
        if (hackId === id && !force) {
          return cb(docs);
        }
        return $http.get("http://www.ethercalc.com/_/" + id + "/csv").success(function(csv){
          var entries, res$, i$, ref$, len$, line, that, ref1$, url, title, rest, entry;
          hackId = id;
          docs.length = 0;
          res$ = [];
          for (i$ = 0, len$ = (ref$ = csv.split(/\n/)).length; i$ < len$; ++i$) {
            line = ref$[i$];
            if (that = line) {
              ref1$ = line.split(/,/), url = ref1$[0], title = ref1$[1], rest = slice$.call(ref1$, 2);
              title = replace$.call(title, /"/g, '');
              entry = import$({
                title: title,
                id: that[1]
              }, (fn$()));
              entry.icon == null && (entry.icon = "img/" + entry.type + ".png");
              res$.push(entry);
            }
          }
          entries = res$;
          docs.splice.apply(docs, [0, -1].concat(slice$.call(entries.filter(function(it){
            return it != null;
          }))));
          return cb(docs);
          function fn$(){
            var ref$;
            switch (ref$ = [url], false) {
            case !/^https?:\/\/www\.ethercalc\.com\/(.*)/.test(ref$[0]):
              return {
                type: 'ethercalc'
              };
            case !/https:\/\/docs\.google\.com\/document\/(?:d\/)?([^\/]+)\//.test(ref$[0]):
              return {
                type: 'gdoc'
              };
            case !/https:\/\/docs\.google\.com\/spreadsheet\/ccc\?key=([^\/?&]+)/.test(ref$[0]):
              return {
                type: 'gsheet'
              };
            case !/https:\/\/docs\.google\.com\/drawings\/(?:d\/)?([^\/]+)\//.test(ref$[0]):
              return {
                type: 'gdraw'
              };
            case !/https:\/\/docs\.google\.com\/presentation\/(?:d\/)?([^\/]+)\//.test(ref$[0]):
              return {
                type: 'gpresent'
              };
            case !/https?:\/\/hackpad\.com\/(?:.*?)-([\w]+)(\#.*)?$/.test(ref$[0]):
              return {
                type: 'hackpad'
              };
            case !/^https?:\/\//.test(ref$[0]):
              return {
                type: 'url',
                id: encodeURIComponent(encodeURIComponent(url)),
                icon: "http://g.etfv.co/" + encodeURIComponent(url)
              };
            default:
              return typeof console != 'undefined' && console !== null ? console.log('unrecognized', url) : void 8;
            }
          }
        });
      }
    };
  })
});
function import$(obj, src){
  var own = {}.hasOwnProperty;
  for (var key in src) if (own.call(src, key)) obj[key] = src[key];
  return obj;
}
}).call(this);

(function() {
  angular.element(document).ready(function(){
  return angular.bootstrap(document, ['app']);
});
}).call(this);

