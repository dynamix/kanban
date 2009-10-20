module Admin

  module PublicHelper

    ##
    # Quick edit usage:
    #
    #     <%= quick_edit(:message => "Edit this article", :path => "articles/edit/#{@article.id}") %>
    #
    # If user is logged in Typus, a link will appear on the top/right of 
    # the pages where you insert this helper.
    #
    def quick_edit(*args)

      options = args.extract_options!

      <<-HTML
<script type="text/javascript">
  document.write('<script type="text/javascript" src="#{admin_quick_edit_path}?#{options.to_query}" />');
</script>
      HTML

    end

  end

end