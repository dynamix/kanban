module Typus

  module InstanceMethods

    include ActionView::Helpers::UrlHelper

    # OPTIMIZE
    def typus_preview_on_table(attribute)

      attachment = attribute.split('_file_name').first
      file_preview = Typus::Configuration.options[:file_preview]
      file_thumbnail = Typus::Configuration.options[:file_thumbnail]

      if send(attachment).styles.member?(file_preview) && send("#{attachment}_content_type") =~ /^image\/.+/
        <<-HTML
<script type="text/javascript" charset="utf-8">
  $(document).ready(function() { $("##{to_dom}").fancybox(); });
</script>
<a id="#{to_dom}" href="#{send(attachment).url(file_preview)}" title="#{typus_name}">#{send(attribute)}</a>
        HTML
      else
        <<-HTML
<a href="#{send(attachment).url}">#{send(attribute)}</a>
        HTML
      end
    end

    # OPTIMIZE
    def typus_preview(attribute)

      attachment = attribute.split('_file_name').first

      case send("#{attachment}_content_type")
      when /^image\/.+/
        file_preview = Typus::Configuration.options[:file_preview]
        file_thumbnail = Typus::Configuration.options[:file_thumbnail]
        if send(attachment).styles.member?(file_preview) && send(attachment).styles.member?(file_thumbnail)
          <<-HTML
<script type="text/javascript" charset="utf-8">
  $(document).ready(function() { $("##{to_dom}").fancybox(); });
</script>
<a id="#{to_dom}" href="#{send(attachment).url(file_preview)}" title="#{typus_name}">
<img src="#{send(attachment).url(file_thumbnail)}" />
        </a>
          HTML
        elsif send(attachment).styles.member?(file_thumbnail)
          <<-HTML
<script type="text/javascript" charset="utf-8">
  $(document).ready(function() { $("##{to_dom}").fancybox(); });
</script>
<a href="#{send(attachment).url}" title="#{typus_name}">
<img src="#{send(attachment).url(file_thumbnail)}" />
        </a>
          HTML
        elsif send(attachment).styles.member?(file_preview)
          <<-HTML
<img src="#{send(attachment).url(file_preview)}" />
          HTML
        else
          <<-HTML
<a href="#{send(attachment).url}">#{send(attribute)}</a>
          HTML
        end
      else
        <<-HTML
<a href="#{send(attachment).url}">#{send(attribute)}</a>
        HTML
      end

    end

  end

end

ActiveRecord::Base.send :include, Typus::InstanceMethods