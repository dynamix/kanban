Class("ItemController", {
  isa: Controller,
  
  after: {
    initialize : function() {
      this.enable_drag_n_drop();
    }
  },
  
  methods: {
    enable_drag_n_drop : function (){
      $('ul.dnd').sortable({
          connectWith: 'ul.dnd', 
          dropOnEmpty: true, 
          tolerance: 'pointer',
          stop: function(event, ui){
            var el = ui.item
            var parent = $(el).parent();
            var index = parent.children().index(el) + 1;
            jQuery.post(parent.attr('href'), 
              {
                'index': index,
                'target_lane_id': parent.attr('id'),
                'id': el.attr('id')
              }
            );
          }
      });
    }
  }
});