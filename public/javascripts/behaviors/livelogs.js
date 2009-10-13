Class("LivelogController", {
  isa: ItemController,
  
  click : function() { return {
    '#item-form-submit-put'   : this.on('show', this.update_item),
    'li.item'                 : this.on('show', this.item_click)
  }}
});