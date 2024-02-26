
def add_includes(site, markdown_extensions, page)
  #puts page.relative_path
  
  if (markdown_extensions.include?(File.extname(page.relative_path)) || File.extname(page.relative_path) == ".html") # && false == page.is_a?(Jekyll::Page)
    #puts "------------------------------------"
    #puts page.relative_path
    #puts "------------------------------------"

    #if page.respond_to?(:content)
      page.content = "{% include doc/common_snippets %}\n" + page.content
    #end
  end # if extension is matching
end # def do_site_pre_render_work
    
Jekyll::Hooks.register :site, :pre_render do |site|

  markdown_extensions = site.config['markdown_ext'].split(',').map { |ext| ".#{ext.strip}" }

  site.layouts.each_value do |layout|
    add_includes(site, markdown_extensions, layout)
  end
  #puts ""

  site.pages.each do |page|
    add_includes(site, markdown_extensions, page)
  end
  #puts ""

  site.documents.each do |document|
    add_includes(site, markdown_extensions, document)
  end
  #puts ""

end