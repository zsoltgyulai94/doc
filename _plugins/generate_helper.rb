require 'fileutils'
require 'liquid'

module Jekyll
  class GeneratorHelpers < Generator

    private

    def do_work(site, markdown_extensions, page, needs_links)
      #puts page.relative_path
      
      if (markdown_extensions.include?(File.extname(page.relative_path)) || File.extname(page.relative_path) == ".html") # && false == page.is_a?(Jekyll::Page)
        #puts "------------------------------------"
        #puts page.relative_path
        #puts "------------------------------------"

        #if page.respond_to?(:content)
          page.content = "{% include doc/common_snippets %}\n" + page.content
        #end

        if needs_links
          # Skip and warn about pages without an 'id' property
          if page.data["id"]
            page_id = page.data["id"].to_s
            # Not removing now the leaign / to support proper root references as well everywhere
            # links must be used via the markdown_link include (or with the '| relative_url' filter) that will handle this 
            page_url = page.url.sub(/\.[^.]+$/, "") # page.url.sub(/^\//, "").sub(/\.[^.]+$/, "")
            page_path = page.destination("").split("_site/").last  # Get the path to the generated HTML file
            #puts page_id
            #puts page_url
            #puts page_path

            # FIXME: Find a render pass that already did this, and use the already rendered page instead
            #        This requires a double rendering this way unfortunately :S
            #
            # Render the page content to HTML using the Markdown converter
            renderer = site.find_converter_instance(Jekyll::Converters::Markdown)
            page_content = renderer.convert(page.content)

            # Extract headings from the rendered content
            headings = page_content.scan(/<h([1-6]).*id=\"(.*?)\">(.*?)<\/h\1>/)
            #puts headings
            #puts ""

            headings.each do |heading|
              #heading_level = heading[0].to_i
              heading_id = heading[1]
              heading_text = heading[2]

              # Create links data for the heading
              link_data = {
                "id" => page_id + "##{heading_id}",
                "url" => page_url + "##{heading_id}",
                "title" => '"' + heading_text + '"'
              }

              # Write data to separate YAML file for each heading
              file_path = "_data/links/#{page_id}##{heading_id}.yml"
              write_yaml_file(file_path, link_data)
            end

            # Create links data for the page
            page_title = page.data["short_title"] || page.data["title"]
            page_link_data = {
              "id" => page_id,
              "url" => page_url,
              "title" => '"' + page_title + '"'
            }
            # Write data to separate YAML file for each page
            page_file_path = "#{page_id}.yml"
            page_file_path = "_data/links/" + page_file_path.gsub(/\/|:|\s/, "-").downcase
            write_yaml_file(page_file_path, page_link_data)
          
          else
            puts "Missing 'id:' property in file " + page.relative_path
          end
        end # if needs_links
      end # if extension is matching
    end # def do_work
    
    def write_yaml_file(file_path, data)
      header = "# ---------------------------------------------\n" + 
               "# This file is auto generated during site build\n" +
               "#      - DO NOT EDIT -\n" +
               "# ---------------------------------------------\n\n"

      FileUtils.mkdir_p(File.dirname(file_path))
      File.open(file_path, "w") do |file|
        file.write(header)
        
        file.write("id: " + data["id"] + "\n")
        file.write("url: " + data["url"] + "\n")
        file.write("title: " + data["title"] + "\n")
      end
    end

    public

    def generate(site)
      markdown_extensions = site.config['markdown_ext'].split(',').map { |ext| ".#{ext.strip}" }

      site.layouts.each_value do |layout|
        do_work(site, markdown_extensions, layout, false)
      end
      #puts ""

      site.pages.each do |page|
        do_work(site, markdown_extensions, page, true)
      end
      #puts ""

      site.documents.each do |document|
        do_work(site, markdown_extensions, document, true)
      end
      #puts ""
    end
  end
end
