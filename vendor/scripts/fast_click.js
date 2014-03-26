/**
 * @author Joe Gaudet - joe@learndot.com
 * @copyright  ©2012 Matygo Educational Incorporated operating as Learndot
 * @license  Licensed under MIT license (see LICENSE.md)
 */
app = angular.module('fastClick', []).provider('Modernizr', function () {
  'use strict';
  this.$get = function () {
    return Modernizr || {};
  };
});
app.directive('fastClick', function ($parse, Modernizr) {

  'use strict';

  return {
    restrict: 'A',
    link: function (scope, element, attrs) {
      /**
       * Parsed function from the directive
       * @type {*}
       */
      var fn = $parse(attrs.fastClick),


        /**
         * Track the start points
         */
        startX,

        startY,

        /**
         * Whether or not we have for some reason
         * cancelled the event.
         */
        canceled,

        /**
         * Our click function
         */
        clickFunction = function (event) {
          if (!canceled) {
            scope.$apply(function () {
              fn(scope, {$event: event});
            });
          }
        };


      /**
       * If we are actually on a touch device lets
       * setup our fast clicks
       */
      if (Modernizr.touch) {

        element.on('touchstart', function (event) {
          event.stopPropagation();

          var touches = event.originalEvent.touches;

          startX = touches[0].clientX;
          startY = touches[0].clientY;

          canceled = false;
        });

        element.on('touchend', function (event) {
          event.stopPropagation();
          clickFunction();
        });

        element.on('touchmove', function (event) {
          var touches = event.originalEvent.touches;

          // handles the case where we've swiped on a button
          if (Math.abs(touches[0].clientX - startX) > 10 ||
            Math.abs(touches[0].clientY - startY) > 10) {
            canceled = true;
          }
        });
      }

      /**
       * If we are not on a touch enabled device lets bind
       * the action to click
       */
      if (!Modernizr.touch) {
        element.on('click', function (event) {
          console.log('not touch!');
          clickFunction(event);
        });
      }
    }
  };
});


app.provider('Modernizr', function () {

  'use strict';

  this.$get = function () {
    return Modernizr || {};
  };

});

