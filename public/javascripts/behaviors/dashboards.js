Class("DashboardController", {
  isa: ItemController,
  
  click : function() { return {
    '#item-form-submit-put'   : this.on('show', this.update_item),
    'li.item'                 : this.on('show', this.item_click),
    'a.add-item-link'         : this.on('show', this.show_create_item_dialog ),
    '#item-form-submit-post'  : this.on('show', this.post_create_new_item),  
    '.delete a'               : this.on('show', this.delete_item)
  }},
  
  after: {
    initialize : function() {
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