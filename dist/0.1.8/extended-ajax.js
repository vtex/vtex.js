/* vtex.js 0.1.8 */
(function() {
  var AjaxQueue, uniqueHashcode;

  uniqueHashcode = (function(_this) {
    return function(str) {
      var char, charcode, hash, _i, _len;
      hash = 0;
      for (_i = 0, _len = str.length; _i < _len; _i++) {
        char = str[_i];
        charcode = char.charCodeAt(0);
        hash = ((hash << 5) - hash) + charcode;
        hash = hash & hash;
      }
      return hash.toString();
    };
  })(this);

  AjaxQueue = function(ajax) {
    var theQueue;
    theQueue = $({});
    return function(ajaxOpts) {
      var abortFunction, dfd, jqXHR, promise, requestFunction;
      jqXHR = void 0;
      dfd = $.Deferred();
      promise = dfd.promise();
      requestFunction = function(next) {
        jqXHR = ajax(ajaxOpts);
        return jqXHR.done(dfd.resolve).fail(dfd.reject).then(next, next);
      };
      abortFunction = function(statusText) {
        var index, queue;
        if (jqXHR) {
          return jqXHR.abort(statusText);
        } else {
          queue = theQueue.queue();
          index = [].indexOf.call(queue, requestFunction);
          if (index > -1) {
            queue.splice(index, 1);
          }
          dfd.rejectWith(ajaxOpts.context || ajaxOpts, [promise, statusText, ""]);
          return promise;
        }
      };
      theQueue.queue(requestFunction);
      promise.abort = abortFunction;
      return promise;
    };
  };

  window.AjaxQueue = AjaxQueue;

}).call(this);
