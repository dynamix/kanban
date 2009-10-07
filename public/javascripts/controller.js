// controller meta class .. provides event methods
Class("ControllerMetaclass", {
    isa: Joose.Class,
    has: {
        events: {
            is: "rw",
            init: {}
        }
    },
    methods : (function () {
      var extensions = {};
      event_functions = ['click','change','focus','blur','keyup']; // what else?
      $.each(event_functions, function (idx) {
        var fnc_name = event_functions[idx];
        extensions['handleProp'+fnc_name] = function (fnc) {
          this.getEvents()[fnc_name] = fnc;
        };
      });
      return extensions;
    })()
});


Class("Controller", {
  meta: ControllerMetaclass,
  
  has: {
    action: {
      is: rw,
      init: ""
    }
  },
  
  methods: {
    
    initialize: function (action) {
      this.setAction(action);
      var self     = this;
      var meta   = this.meta;
      var events = meta.getEvents();

      // bind jquery events
      $.each(events, function (dom_event, fnc) {
        // gather event handlers - key == event, fnc = function
        $.each(fnc.apply(self), function(selector,method) {
          if(method) {
            // wrap around for jquery stuff
            
            var wraped_method = function () {
              // this is now the jquery object
              var j = $(this);
              // but not for our event handler
              return method.apply(self,[j]);
            };
            // bind a livequery
            $(selector).livequery(dom_event,wraped_method);
          }
        });
      });
    },
    on : function() {
      var self = this;
      if(arguments.length > 1) {
        if($.inArray(this.getAction(),arguments) != -1) {
          return arguments[arguments.length - 1];
        }
      }
      return null;
    },
    on_modify : function(method) {
      return this.on('new','create','edit','update',method);
    },
    
    _new : function() {},
    _edit : function() {},
    _create : function() {},
    _update : function() {},
    _show : function() {},
    _index : function() {},
    _destroy : function() {}
  }
});