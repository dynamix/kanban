Class("BacklogController", {
  isa: ItemController,
  
  click : function() { return {
    'a#item-link'             : this.on('show', this.show_overlay),
    '#item-form-submit-post'  : this.on('show', this.create_new_item),
    '#item-form-submit-put'   : this.on('show', this.update_item),
    'li.item'                 : this.on('show', this.item_click)
  }},
  methods:{
    show_overlay : function (j){
      $('#item-overlay').modal();
    },
    create_new_item :function (j){
      var self = this;
      var form = $('#new_item');
      jQuery.post(form.attr('action'), form.serialize(), function(data, textStatus){
        var backlog = $('.dnd[name=backlog]');
        backlog.prepend(data);
        //backlog.children('li.item:first').bind('click', self.bind_item_click());
      });
      $('a.modalCloseImg').click();
      return false;
    }
  }
});