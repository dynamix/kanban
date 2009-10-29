Class("BacklogController", {
  isa: ItemController,
  
  click : function() { return {
    '#item-form-submit-post'  : this.on('show', this.post_create_new_item),
    '#item-form-submit-put'   : this.on('show', this.update_item),
    'a.add-item-link'         : this.on('show', this.show_create_item_dialog ),
    'li.item'                 : this.on('show', this.item_click),
    '.delete a'               : this.on('show', this.delete_item)
    
  }}
  
});