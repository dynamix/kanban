Class("DashboardController", {
  isa: ItemController,
  
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