Class("BacklogController", {
  isa: ItemController,
  click : function() { return {
    'a#item-link'        : this.on('show', this.show_overlay),
    '#item-form-submit'  : this.on('show', this.create_new_item)
  }},
  methods:{
    show_overlay : function (j){
      $('#item-overlay').modal();
    },
    create_new_item :function (j){
      var form = $('#new_item');
      jQuery.post(form.attr('action'), form.serialize(), function(data, textStatus){
        $('.dnd[name=backlog]').prepend(data);
      });
      $('a.modalCloseImg').click();
      return false;
    }
  }
});