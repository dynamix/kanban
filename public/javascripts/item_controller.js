Class("ItemController", {
  isa: Controller,

  has : {
    is_click : true
  },
  
  after: {
    initialize : function() {
      this.enable_drag_n_drop();
    }
  },
  
  methods: {
    update_item :function (j){
      var self = this;
      var form = $('.edit_item');
      var id = form.attr('id').substr(10);
      jQuery.post(form.attr('action'), form.serialize() + "&_method=put", function(data, textStatus){
        $('li#' + id).html(data);
      });
      $('a.modalCloseImg').click();
      return false;
    },
    item_click : function(j){
      var self = this;
      if(self.is_click == null)
        self.is_click = true;
      if(self.is_click)
        self.load_edit_overlay(j.attr('href'));
      else
        self.is_click = true; // was drag'n'drop, enable click again
    },
    load_edit_overlay : function(url){
      $('#item-edit-overlay').load(url, '', function (responseText, textStatus, XMLHttpRequest) {
        $('#item-edit-overlay').modal();
      });
    },
    enable_drag_n_drop : function(){
      var self = this;
      $('ul.dnd').sortable({
          connectWith: 'ul.dnd', 
          dropOnEmpty: true, 
          tolerance: 'pointer',
          beforeStop: function(event, ui){
            self.is_click = false; // disable click
            var column = ui.item.parent();
            var limit = 0;
            var super_target = false;
            var super_column = false;
            if(column.parents(".super_column").length == 1){
              super_column = column.parents(".super_column:first");
              limit = parseInt(super_column.attr('limit'));
              super_target = true;
            }else{
              limit = parseInt(column.attr('limit'));
            }
            if(super_target){
              if(super_column.attr('id') != $(this).parents(".super_column:first").attr('id') && limit > 0 && ($('li', super_column).length > (limit + 1)))
                return false;
            }else{
              if(limit > 0 && column.children().length > (limit + 1))
                return false;
            }
          },
          stop: function(event, ui){
            var el = ui.item;
            var parent = $(el).parent();
            var index = parent.children().index(el) + 1;
            jQuery.post(parent.attr('href'), 
              {
                'index': index,
                'target_lane_id': parent.attr('id'),
                'id': el.attr('id')
              },
              function(data, bla){
                self.is_click = true; // disable click
              }
            );
            if(parent.hasClass('trash')){
              $(el).remove();
            }
          }
      });
    }
  }
});