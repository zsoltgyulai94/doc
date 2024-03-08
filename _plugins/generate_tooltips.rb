require 'fileutils'
require 'liquid'

module Jekyll
  class TooltipGen
    class << self

    private

      def add_matching_files(file_names, folder_path, pattern)
        fullPattern = File.join(folder_path, '*') #pattern
                
        # NOTE: This is not a real reg-exp https://docs.ruby-lang.org/en/master/Dir.html#method-c-glob
        #       and actually, how it works is a mess
        #       Trying to use a manual solution instead, filtering * with useable regex 
        Dir.glob(fullPattern, File::FNM_EXTGLOB).each do |file|
          if file.match?(pattern)
            #puts "match: " + file
            file_names << file
          end
        end
        file_names = file_names.sort
        puts file_names
      end

      def has_anchor?(url)
        anchor_regex = /#.+/
        !!(url =~ anchor_regex)
      end

      # More about rendering insights
      # https://humanwhocodes.com/blog/2019/04/jekyll-hooks-output-markdown/
      #
      def replace_text(page, content, text_to_search, id, url, description)
        #puts content

        # Regular expression pattern to match HTML comments
        html_comment_pattern = /<!--.*?-->/m
        # Regular expression pattern to match Liquid blocks
        liquid_block_pattern = /{%.*?%}|\{\:.*?\}/m
        # Regular expression pattern to match special Markdown blocks
        # Unlike the above this needs grouping as we use do |match| for enumeration
        special_markdown_blocks_pattern = /(```.*?```|\[.*?\]\(.*?\)|\[.*?\]\{.*?\}|^#+\s.*?$)/m # [^`]*`|
        url_has_anchor = has_anchor?(url)

        # Split the content by HTML comments and special Markdown blocks
        parts = content.split(/(#{html_comment_pattern})/m)
        #puts parts
        parts.each_with_index do |part, index|
          #puts "---------------\nindex: " + index.to_s + "\npart: " + part

          if index.even? # Content outside of HTML comments
            # Split the content by HTML comments and special Markdown blocks
            liquid_parts = part.split(/(#{liquid_block_pattern})/m)
            #puts parts
            liquid_parts.each_with_index do |liquid_part, liquid_index|
              #puts "---------------\nliquid_index: " + liquid_index.to_s + "\nliquid_part: " + liquid_part

              if liquid_index.even? # Content outside of Liquid blocks
                # Split the content by special Markdown blocks
                markdown_parts = liquid_part.split(special_markdown_blocks_pattern)
                #puts markdown_parts
                markdown_parts.each_with_index do |markdown_part, markdown_index|            
                  #puts "---------------\ntext_to_search: " + text_to_search + "\nmarkdown_index: " + markdown_index.to_s + "\nmarkdown_part: " + markdown_part

                  if markdown_index.even? # Content outside of special Markdown blocks
                    part_modified = false
                    #patterns = [ '/(^|[\s.,;:\'])(' + Regexp.escape(text_to_search) + ')([\s.,;:\']|\z)/', '/(`)(' + Regexp.escape(text_to_search) + ')(`)/' ]

                    #patterns.each do |pattern|            
                    #  puts "pattern: " + pattern
                      markdown_part = markdown_part.gsub(/(^|[\s.;:'`])(#{Regexp.escape(text_to_search)})([\s.;:'`]|\z)/) do |match|
                        # left_separator = $1
                        # matched_text = $2
                        # right_separator = $3
                        # puts "match: " + match
                        # puts "left_separator: " + left_separator
                        # puts "matched_text: " + matched_text
                        # puts "right_separator: " + right_separator

                        if ($1 != '`' and $3 != '`') or ($1 == '`' and $3 == '`') # we accept exact surrounding `` pairs only as a direct signal for a tooltip (and the default markdown highlighting)
                          part_modified = page.data["modified"] = true

                          left_separator = ($1 == '`' ? '' : $1)
                          matched_text = $2
                          right_separator = ($3 == '`' ? '' : $3)

                          tooltip = left_separator + '{% include markdown_link id="' + id + '" title="%MATCH%"' + (url_has_anchor || description ? ' withTooltip="yes"' : '') + ' %}' + right_separator #'abrakadabra'
                          replacement_text = tooltip.gsub(/#{Regexp.escape('%MATCH%')}/, matched_text)
                          puts "replacement_text: " + replacement_text

                          # Take care, this must be the last one in this block!
                          replacement_text
                        end
                      end
                    #end
                    if part_modified
                      #puts "new markdown_part: " + markdown_part
                      markdown_parts[markdown_index] = markdown_part
                    end
                  else
                    #puts "markdown_index: " + markdown_index.to_s + "\nmarkdown_part: " + markdown_part
                  end
                end

                # Join the modified markdown parts back together
                liquid_parts[liquid_index] = markdown_parts.join

              else
                #puts "liquid_index: " + liquid_index.to_s + "\nliquid_part: " + liquid_part
              end
            end

            # Join the modified liquid parts back together
            parts[index] = liquid_parts.join

          else
            #puts "index: " + index.to_s + "\npart: " + part
          end
        end

        # Join the parts back together
        modified_content = parts.join

        return modified_content
      end

      def write_to_file(file_path, content)
        File.open(file_path, "w") do |file|
          file.write(content)
        end
      end
      
    public

      def generate_tooltips(site, markdown_extensions, page_links, page, payload, write_back)
        #puts page.relative_path
        
        if (markdown_extensions.include?(File.extname(page.relative_path)) || File.extname(page.relative_path) == ".html")
          # return if 
          #           page.relative_path != "_admin-guide/020_The_concepts_of_syslog-ng/008_Message_representation.md" and 
          #           page.relative_path != "_admin-guide/070_Destinations/020_Discord/README.md" and          
          #           page.relative_path != "_admin-guide/120_Parser/README.md" and
          #           page.relative_path != "_admin-guide/020_The_concepts_of_syslog-ng/004_Timezones_and_daylight_saving.md"
                    # and page.relative_path != "_admin-guide/060_Sources/140_Python/001_Python_logmessage_API.md"
          puts "------------------------------------"
          puts page.relative_path
          puts "------------------------------------"

          content = page.content
          #puts content

          processed_titles = {}
          page.data["modified"] = false
          page_links.each do |link_data|
            title = link_data["title"]
            #puts "searching for " + title

            # process only once a given title in the given page
            next if processed_titles[title]

            # otherwise add to the processsed list and process it
            processed_titles[title] = true
            content = replace_text(page, content, title, link_data["id"], link_data["url"], link_data["description"])
          end

          if page.data["modified"]
            page.content = content
            #puts "\n\n\n" + page.content
            if write_back
              write_to_file(page.path, page.content)
            end
          end
          #exit
        end # if extension is matching
      end # def do_site_post_render_work

      def gen_page_link_data(links_dir, link_files_pattern)
        excluded_titles = YAML.load_file(File.join('_data', 'excluded_titles.yml'))
        processed_titles = {}
        page_link_data_array = []
        link_file_names = []
        add_matching_files(link_file_names, links_dir, link_files_pattern)
                            
        link_file_names.each do |file_name|
          #puts file_name
          yaml_content = YAML.load_file(file_name)

          # Extract the necessary data from the YAML content
          page_id = yaml_content['id']
          page_url = yaml_content['url']
          page_title = yaml_content['title']
          page_description = yaml_content['description']
          chars_to_remove = %{"'!?.:;}
          page_description = page_description.gsub(/\A[#{Regexp.escape(chars_to_remove)}]+|[#{Regexp.escape(chars_to_remove)}]+\z/, '')
          #puts "page_description: " + page_description
          page_title = page_title.gsub(/\A[#{Regexp.escape(chars_to_remove)}]+|[#{Regexp.escape(chars_to_remove)}]+\z/, '')
          #puts "page_title: " + page_title
          if page_title.length == 0
            page_title = link_data["title"]
          end

          # Process only once a given title, first one wins now
          # skip also excluded ones
          next if processed_titles[page_title] or (excluded_titles and false == excluded_titles.empty? and excluded_titles[page_title])
          # otherwise add to the processsed list and process it
          processed_titles[page_title] = true

          # Create a page_link_data object
          page_link_data = {
            "id" => page_id,
            "url" => page_url,
            "title" => page_title,
            "description" => (page_description.length > 0 ? true : false)
          }

          # Add the page_link_data object to the array
          page_link_data_array << page_link_data
        end

        page_link_data_array = page_link_data_array.sort_by { |page| page["title"] }.reverse
        puts page_link_data_array

        return page_link_data_array
      end

    end # class << self
  end # class TooltipGen
end # module jekyll


Jekyll::Hooks.register :site, :pre_render do |site, payload|

  shoud_build_tooltips = (ENV['JEKYLL_BUILD_TOOLTIPS'] == 'yes')
  shoud_build_persistent_tooltips = (ENV['JEKYLL_BUILD_PERSISTENT_TOOLTIPS'] == 'yes')

  if shoud_build_tooltips    
    markdown_extensions = site.config['markdown_ext'].split(',').map { |ext| ".#{ext.strip}" }
    # Skip shorter than 3 letter long (e.g. Glossary header) anchor items (for testing: https://rubular.com/)
    page_links = Jekyll::TooltipGen.gen_page_link_data('_data/links', /\/adm-(([^#]+)|(.*\#{1}.{3,}))\.yml\z/)
    #page_links = Jekyll::TooltipGen.gen_page_link_data('_data/links', /\/(adm|dev|doc)-(([^#]+)|(.*\#{1}.{3,}))\.yml\z/)
    #page_links = Jekyll::TooltipGen.gen_page_link_data('_data/links', 'adm-temp-macro-ose#message.yml')
    #puts page_links

    site.pages.each do |page|
      Jekyll::TooltipGen.generate_tooltips(site, markdown_extensions, page_links, page, payload, shoud_build_persistent_tooltips)
    end
    #puts ""

    site.documents.each do |document|
      Jekyll::TooltipGen.generate_tooltips(site, markdown_extensions, page_links, document, payload, shoud_build_persistent_tooltips)
    end
    #puts ""    
  end

end