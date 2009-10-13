Class("DashboardController", {
  isa: ItemController,
  
  click : function() { return {
    '#item-form-submit-put'   : this.on('show', this.update_item),
    'li.item'                 : this.on('show', this.item_click)
  }},
  
  after: {
    initialize : function() {
     // this.enable_live_drop();
    }
  },

  methods:{
    enable_live_drop : function(){
      $('li.item').draggable();
      $('.livelog').droppable({
        accept: 'li.item', 
        drop: function(e, ui){
          var id = $(ui.draggable).attr('id');
          var parent = $('.livelog:first');
          $(ui.draggable).remove();
          jQuery.post(parent.attr('href'), 
            {
              'index': 1,
              'target_lane_id': parent.attr('id'),
              'id': id
            }
          );
        }
      });
    }
  }
});