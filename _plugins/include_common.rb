module Jekyll
  class PreRenderInclude < Generator

    def alter(markdown_extensions, item)        
        if markdown_extensions.include?(File.extname(item.relative_path)) || File.extname(item.relative_path) == ".html"
          #puts item.relative_path
          item.content = "{% include doc/common-snippets %}\n" + item.content #if document.respond_to?(:content)
        end
    end

    def generate(site)
      markdown_extensions = site.config['markdown_ext'].split(',').map { |ext| ".#{ext.strip}" }

      site.pages.each do |page|
        alter(markdown_extensions, page)
      end
      #puts ""

      site.layouts.each_value do |layout|
        alter(markdown_extensions, layout)
      end
      #puts ""

      site.documents.each do |document|
        alter(markdown_extensions, document)
      end
      #puts ""
    end
  end
end
