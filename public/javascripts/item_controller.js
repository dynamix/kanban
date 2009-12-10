Class("ItemController", {
  isa: Controller,

  has : {
    is_click : true
  },
  
  after: {
    initialize : function() {
      // $('.urgent').pulse({speed: 750,
      //   borderColors: ['#ee2200','#ffaa00']});
      var self = this;
      $(window).resize(function(){
        self.fit_to_screen();
      });
      this.fit_to_screen();
      this.enable_drag_n_drop();
      // apply tooltips
      $('.item').each(function(idx,e) {
        $(e).qtip({
          delay: 300,
          position: {
            corner: {
              target: 'bottomLeft',
              tooltip: 'topLeft'
            },  
            adjust: {
              screen: true
            }
          },
          content:$('.tip',e).html()  ,
          
          style: {
            width: 500
          }
        });
      });
      
    }
  },
  
  methods: {
    fit_to_screen : function() {
      var lanes = $('.lane:not(.super)');
      var width = ($('#content').width() - 10 )/ lanes.length;
      
      if(lanes.length == 2)
        width = width - 20;
      
      
      // substract padding, marigin and border
      var first_lane = $(lanes.get(0));
      var delta = first_lane.outerWidth(true) - first_lane.width();
      lanes.width(Math.floor(width) - delta);
      
      // set the width of superlanes
      $('.lane.super').each( function(idx, super_lane) {
        var super_width = 0;
        $('.lane',super_lane).each(function(idx, lane) {
          super_width += $(lane).outerWidth(true);
        });
        $(super_lane).width(super_width);
      });
    },

    delete_item : function(j) { 
      var self = j;
      j.parents('li').fadeOut();
      $.post(j.attr('href'), { '_method':'delete' });
      return false;
    },

    update_item :function (j){
      var self = this;
      var form = $('.edit_item');
      var id = form.attr('id').substr(10);
      jQuery.post(form.attr('action'), form.serialize() + "&_method=put", function(data, textStatus){
        $('li#' + id).html(data).effect("highlight", {color: '#ffbe89'}, 1000);;
      });
      $('a.modalCloseImg').click();
      return false;
    },
    
    show_create_item_dialog : function(j) {
      var limit = j.parents('div.lane').attr('limit');
      if( limit > 0 && j.parents('div.lane').find('li').length >= limit )
      {
        alert('Lane has reach the maximum number of items!');
        return false;
      }
      var form = $('#create-item-modal-box form');
      form.attr('target',j.parents('div.lane').attr('name'));
      form.attr('action', j.attr('href'));
      $('#create-item-modal-box').modal();
      return false;
    },
    
    post_create_new_item :function (j){
      var self = this;
      var form = $('#new_item');
      jQuery.post(form.attr('action'), form.serialize(), function(data, textStatus) {
        var backlog = $('.dnd[name=' + form.attr('target') + ']');
        backlog.prepend(data);
      });
      $.modal.close();
      return false;
    },
    
    item_click : function(j){
      var self = this;
      if(self.is_click == null)
        self.is_click = true;
      if(self.is_click)
        self.load_edit_overlay($('#item_url', j).attr('value'));
      else
        self.is_click = true; // was drag'n'drop, enable click again
    },
    
    load_edit_overlay : function(url){
      $('#item-edit-overlay').load(url, '', function (responseText, textStatus, XMLHttpRequest) {
        $('#item-edit-overlay').modal();
      });
    },
    
    get_limit : function(column) {
      var limit = -1;
       if(column.parents(".super").length == 1){
          super_column = column.parents("div.lane.super:first");
          limit = parseInt(super_column.attr('limit'));
          super_target = true;
        }else{
          limit = parseInt($('ul',column).attr('limit'));
        }
        return limit;
    },

    enable_drag_n_drop : function(){
      var self = this;
      $('ul.dnd').sortable({
          items: 'li',
          connectWith: '.dnd', 
          dropOnEmpty: true, 
          tolerance: 'pointer',
          over : function(event, ui) {
            var column = $(event.target).parent('div.lane');
            var limit = self.get_limit(column);
            var same_lane = event.target == ui.sender.get(0);
            var item_count = $('li',column).length;
            if( column.parent('.super').length > 0 ) 
            {
              item_count = $('li.item',column.parent('.super')).length;
              // also same lane if same super lane
              if(!same_lane)
                same_lane = $(event.target).parents('.super').get(0) == ui.sender.parents('.super').get(0)
            } 
            if( !same_lane && limit > 0 && limit < item_count ) {
              column.css('background-color','red');
            } 
						// else {
						//               column.pulse({speed: 750,
						//                   opacityRange: [0.4,0.9]});
						//             }
          },
          out : function(event, ui) {
            var column = $(event.target).parents('div.lane');
            column.recover();
          },
          
          beforeStop: function(event, ui){
            self.is_click = false; // disable click
            var column = ui.item.parent();
            var limit = 0;
            var super_target = false;
            var super_column = false;
            if(column.parents(".lane.super").length == 1){
              super_column = column.parents(".lane.super:first");
              limit = parseInt(super_column.attr('limit'));
              super_target = true;
            }else{
              limit = parseInt(column.attr('limit'));
            }
            if(super_target){
              if(super_column.attr('id') != $(this).parents(".lane.super:first").attr('id') && limit > 0 && ($('li.item', super_column).length > (limit + 1)))
                return false;
            }else{
              if(limit > 0 && column.children().length > (limit + 1))
                return false;
            }
          },
          stop: function(event, ui){
            var el = ui.item;
            var parent = $(el).parent();
            var id = $(el).attr('id');
            var index = parent.children().index(el) + 1;
            jQuery.post(parent.attr('href'), 
              {
                'index': index,
                'target_lane_id': parent.attr('id'),
                'id': el.attr('id')
              },
              function(data, textStatus){  
                self.is_click = true; // disable click
                $('li#' + id).html(data).effect("highlight", {color: '#ffbe89'}, 1000);
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