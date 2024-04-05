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
        #puts file_names
      end

      def has_anchor?(url)
        anchor_regex = /#.+/
        !!(url =~ anchor_regex)
      end

      def save_from_markdownify(text)
        text = text.gsub(/\'/, "&#8217;")   # '
        text = text.gsub(/\|/, "&#124;")    # |
       end

      def make_tooltip(page, page_links, id, url, needs_tooltip, match)
        match_parts = match.split(/\|/)
        if match_parts.length > 1
          #puts "match_parts: #{match_parts}"
          match = match_parts[0]
          id = match_parts[1]
          url = page_links[id]["url"]
          external_url = false
          if url =~ %r{^\w+://}
            external_url = true
          else
            base_url = page.site.config["baseurl"]
            url = base_url + url
          end
        end
        
        match = save_from_markdownify(match)
        replacement_text = '<a href="' + url + '" class="nav-link' + (needs_tooltip ? ' content-tooltip' : '') + '"' + (external_url ? ' target="_blank"' : '') + '>' + match + '</a>'
        puts "replacement_text: " + replacement_text
        
        return replacement_text
      end

      def process_markdown_part(page, markdown_part, page_links, full_pattern, id, url, needs_tooltip, add_separator)

        markdown_part = markdown_part.gsub(full_pattern) do |match|
          left_separator = $1
          matched_text = $2
          right_separator = $3
          #puts "\nmatch: #{match}\nleft_separator: #{left_separator}\nmatched_text: #{matched_text}\nright_separator: #{right_separator}"

          replacement_text = make_tooltip(page, page_links, id, url, needs_tooltip, matched_text)
          if add_separator
            replacement_text = left_separator + replacement_text + right_separator
          end
          replacement_text
        end

        return markdown_part
      end

      def process_markdown_parts(page, markdown)
        base_url = page.site.config["baseurl"]
        page_links = page.data["page_links"]

        # Regular expression pattern to match special Markdown blocks
        # Unlike the others this needs grouping as we use do |match| for enumeration
        # NOTE: Use multi line matching as e.g. code blocks can span to multiple lines
        special_markdown_blocks_pattern = /(```.*?```|`.*?`|\[\[.*?\]\]|\[.*?\]\(.*?\)|\[.*?\]\{.*?\}|^#+\s.*?$)/m    # TODO: test needs of |\[.*?\][\s]*\:.*?$
        
        # Split the content by special Markdown blocks
        markdown_parts = markdown.split(special_markdown_blocks_pattern)
        #puts markdown_parts
        markdown_parts.each_with_index do |markdown_part, markdown_index|            
          #puts "---------------\nmarkdown_index: " + markdown_index.to_s + "\nmarkdown_part: " + markdown_part

          page.data["page_links_ids_sorted_by_title"].each do |page_id|
            link_data = page_links[page_id]

            title = link_data["title"]
            id = link_data["id"]
            url = base_url + link_data["url"]
            needs_tooltip = (link_data["description"] || has_anchor?(url))

            #puts "searching for #{title}"
            pattern = Regexp.escape(title)
            #puts "searching for #{pattern}"
            # TODO: Even though this one helps finding the pattern e.g. if it spans to multiple line or separated inside with different whitespaces, but can cause unwanted sideffects and has generation time penalities, revise later!
            pattern = pattern.gsub('\ ', '[\s]+')
            #puts "searching for #{pattern}"

            if markdown_index.even? 
              # Content outside of special Markdown blocks, aka. pure text (NOTE: Also excludes the reqursively self added <a ...>title</a> tooltips/links)

              # Search for known link titles
              # NOTE: Using multi line matching here will not help either if the pattern itself is in the middle broken/spaned to multiple lines, so using whitespace replacements now inside the patter to handle this, see above!
              full_pattern = /([\s.,;:&'(])(#{pattern})([\s.,;:&')])(?![^<]*?<\/a>)/
              markdown_part = process_markdown_part(page, markdown_part, page_links, full_pattern, id, url, needs_tooltip, true)
            else 
              # Content inside of special Markdown blocks

              # Handle own auto tooltip links [[ ]], [[ | ]], [[ |id ]]
              full_pattern = /(\[\[)(#{pattern}|#{pattern}\|.+|.*\|#{id})(\]\])/
              markdown_part = process_markdown_part(page, markdown_part, page_links, full_pattern, id, url, needs_tooltip, false)
            end
          end

          #puts "new markdown_part: " + markdown_part
          markdown_parts[markdown_index] = markdown_part
        end

        # Join the markdown parts back together
        markdown_parts.join
      end

      # More about rendering insights
      # https://humanwhocodes.com/blog/2019/04/jekyll-hooks-output-markdown/
      #
      def process_page(page)
        # Split the content by HTML comments
        parts = page.content.split(/(<!--.*?-->)/m)
        #puts parts
        parts.each_with_index do |part, index|
          #puts "---------------\nindex: " + index.to_s + "\npart: " + part

          if index.even? # Content outside of HTML comments
            parts[index] = process_markdown_parts(page, part)
          else
            #puts "index: " + index.to_s + "\npart: " + part
          end
        end

        # Join the parts back together
        page.content = parts.join
      end

      def write_to_file(file_path, content)
        File.open(file_path, "w") do |file|
          file.write(content)
        end
      end
      
      def process_nav_link_items(items, ndx, nav_links_dictionary)
        items.each do |item|
          item['nav_ndx'] = ndx
          ndx = ndx + 1

          if item['subnav']
            ndx = process_nav_link_items(item['subnav'], ndx, nav_links_dictionary)
          end
          nav_links_dictionary[item['url']] = item
        end
        return ndx
      end

      def is_excluded_title?(excluded_titles, page_title) 
        if excluded_titles and false == excluded_titles.empty?
          # exluded list items can be a regex patters here
          excluded_titles.each do |title|
            title = title.gsub(/\A'|'\z/, '')
            pattern = /^#{title}$/
            #pattern = Regexp.escape(title)
            if page_title.match?(pattern) 
              return true
            end
          end
        end
        return false
      end

    public

      def gen_nav_link_data(nav_links_file)
        nav_links_data = YAML.load_file(nav_links_file)
        #pp nav_links_data
        nav_links_dictionary = {}
        ndx = 0

        nav_links_data.each do |collection_key, collection_value|
          # puts "Collection: #{collection_key}"
          process_nav_link_items(collection_value, ndx, nav_links_dictionary)
        end

        #pp nav_links_dictionary
        return nav_links_dictionary
      end # gen_nav_link_data

      def page_links_ids_sorted_by_title(page_links)
        return page_links.keys.sort_by{ |key| page_links[key]['title'].downcase }.reverse
      end

      def gen_page_link_data(links_dir, link_files_pattern)
        excluded_titles = YAML.load_file(File.join('_data', 'excluded_titles.yml'))
        page_links_dictionary = YAML.load_file(File.join('_data', 'external_links.yml'))
        #page_links_dictionary = {}
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
          chars_to_remove = %{"'} #!?.:;}
          page_description = page_description.gsub(/\A[#{Regexp.escape(chars_to_remove)}]+|[#{Regexp.escape(chars_to_remove)}]+\z/, '')
          #puts "page_description: " + page_description
          page_title = page_title.gsub(/\A[#{Regexp.escape(chars_to_remove)}]+|[#{Regexp.escape(chars_to_remove)}]+\z/, '')
          #puts "page_title: " + page_title
          if page_title.length == 0
            puts "Page title is empty, ID: #{page_id}"
            exit 3
          end

          # Skip excluded titles
          next if is_excluded_title?(excluded_titles, page_title)

          # Create a page_link_data object
          page_link_data = {
            "id" => page_id,
            "url" => page_url,
            "title" => page_title,
            "description" => (page_description.length > 0 ? true : false)
          }

          # Add the page_link_data object to the ID dictionary
          # NOTE: Title duplications are allowed now [[title|id]] format must be used 
          #       to get the propwer matching tooltip for duplicated title items
          page_links_dictionary[page_id] = page_link_data
        end

        # Just for debugging
        # pp page_links_dictionary
        # page_links_ids_sorted_by_title(page_links_dictionary).each do |page_id|
        #   puts page_links_dictionary[page_id]
        # end

        #pp page_links_dictionary
        return page_links_dictionary
      end # gen_page_link_data

      def generate_tooltips(page, write_back)
        puts "------------------------------------"
        puts page.relative_path
        puts "------------------------------------"

        process_page(page)
        #puts "\n\n\n" + page.content

        if write_back
          write_to_file(page.path, page.content)
        end
      end # def generate_tooltips

    end # class << self
  end # class TooltipGen
end # module jekyll

def Jekyll_TooltipGen_debug_page_info(page, details = true)
  puts "\npage: #{page.relative_path}"
  puts "page.url: #{page.url}"

  if details
    page.instance_variables.each do |var|
      if var == :@content or var == :@to_liquid or var == :@output or var == :@excerpt
        puts "  #{var}: (skipped because of its size)"
      else
        if var == :@data
          puts "  #{var}:"
          page.data.each do |key, value|
            puts "    #{key}: #{value}"
          end
        else
          puts "  #{var}: #{page.instance_variable_get(var)}"
        end
      end
    end
  end
end

def Jekyll_TooltipGen_debug_filter_pages?(page)
  debug_pages = {
    "_admin-guide/020_The_concepts_of_syslog-ng/008_Message_representation.md" => true,
    # "_admin-guide/050_The_configuration_file/006_Modules_in_syslog-ng/001_Listing_configuration_options.md" => true,
    "_admin-guide/040_Quick-start_guide/001_Configuring_syslog-ng_on_server_hosts.md" => true,
    # "_admin-guide/190_The_syslog-ng_manual_pages/005_syslog-ng_manual.md" => true,
    # "_admin-guide/110_Template_and_rewrite/000_Customize_message_format/004_Macros_of_syslog-ng.md" => true,
    # "_includes/doc/admin-guide/host-from-macro.md" => true,
    # "_admin-guide/070_Destinations/020_Discord/README.md" => true,
    # "_admin-guide/120_Parser/README.md" => true,
    # "_admin-guide/020_The_concepts_of_syslog-ng/004_Timezones_and_daylight_saving.md" => true,
    # "_admin-guide/120_Parser/022_db_parser/001_Using_pattern_databases/README.md" => true,
    # "_admin-guide/060_Sources/140_Python/001_Python_logmessage_API.md" => true,
  }
  debug_ok = true  
  # Comment this line out if not debugging!!!
  # debug_ok = (debug_pages[page.relative_path] != nil)
  return debug_ok
end

def Jekyll_TooltipGen_hack_description_in(page_has_subtitle, page_has_description, page, desc_hack_separator)
  description = nil
  if page_has_subtitle
    description = page.data["subtitle"]
    #puts "subtitle: #{description}"
  else
    if page_has_description
      description = page.data["description"]
      #puts "description: #{description}"
    end
  end
  if page_has_description || page_has_subtitle
    page.content = page.content + desc_hack_separator + description 
  end
end

def Jekyll_TooltipGen_hack_description_out(page_has_subtitle, page_has_description, page, desc_hack_separator)
  description = nil

  content_parts = page.content.split(desc_hack_separator)
  content_parts.each_with_index do |content_part, content_part_index|            
    #puts "---------------\ncontent_part_index: " + content_part_index.to_s + "\ncontent_part: " + content_part
    if content_part_index.even?
      page.content = content_part
    else
      description = content_part
    end
  end

  if page_has_subtitle
    page.data["subtitle"] = description
    #puts "subtitle: #{description}"
  else
    if page_has_description
      page.data["description"] = description
      #puts "description: #{description}"
    end
  end
end

Jekyll_TooltipGen_desc_hack_separator = '<p>%%%description-separator-DO-NOT-REMOVE%%%</p>'

#
# Some more info about render passes, and why we are using these
#   - https://humanwhocodes.com/blog/2019/04/jekyll-hooks-output-markdown/
#   - https://jekyllrb.com/docs/plugins/hooks/
#   - https://github.com/jekyll/jekyll/blob/12ab35011f6e86d49c7781514f9dd1d92e43ea11/features/hooks.feature#L37
#
Jekyll::Hooks.register :site, :pre_render do |site, payload|

  should_build_tooltips = (ENV['JEKYLL_BUILD_TOOLTIPS'] == 'yes')
  should_build_persistent_tooltips = (ENV['JEKYLL_BUILD_PERSISTENT_TOOLTIPS'] == 'yes')

  if should_build_tooltips
    liquid_options = site.config["liquid"]
    markdown_extensions = site.config['markdown_ext'].split(',').map { |ext| ".#{ext.strip}" }
    # Skip shorter than 3 letter long (e.g. Glossary header) anchor items (for testing: https://rubular.com/)
    page_links = Jekyll::TooltipGen.gen_page_link_data('_data/links', /\/adm-(([^#]+)|(.*\#{1}.{3,}))\.yml\z/)   # /\/(adm|dev|doc)-(([^#]+)|(.*\#{1}.{3,}))\.yml\z/       'adm-temp-macro-ose#message.yml'
    # Sort the page_links dictionary keys based on the "title" values in reverse order case insensitive
    page_links_ids_sorted_by_title = Jekyll::TooltipGen.page_links_ids_sorted_by_title(page_links)
    # Create nav_links dictionary using "url" as key and add nav_ndx to all items based on we can adjust navigation order (in page_pagination.html)
    # TODO: We can replace the nav_gen shell tool now to handle everything related to link generation at a single place
    nav_links = Jekyll::TooltipGen.gen_nav_link_data('_data/navigation.yml')

    [site.pages, site.documents].each do |pages|

      pages.each do |page|
        page_url = page.url.gsub(/\.[^.]+$/, '')
        #puts "page_url: #{page_url}"
        #puts "page: #{page.relative_path}"

        next if false == markdown_extensions.include?(File.extname(page.relative_path)) && File.extname(page.relative_path) != ".html"
        
        link_data = nav_links[page_url]
        if link_data != nil
          page.data['nav_ndx'] = link_data['nav_ndx'] # page_pagination.html will use this as sort value for navigation ordering
        end

        next if false == Jekyll_TooltipGen_debug_filter_pages?(page)

        page.data["page_links"] = page_links
        page.data["page_links_ids_sorted_by_title"] = page_links_ids_sorted_by_title

        page_has_subtitle = (page.data["subtitle"] && false == page.data["subtitle"].empty?)
        page_has_description = (page.data["description"] && false == page.data["description"].empty?)

        Jekyll_TooltipGen_hack_description_in(page_has_subtitle, page_has_description, page, Jekyll_TooltipGen_desc_hack_separator)

        # create a template object
        template = site.liquid_renderer.file(page.path).parse(page.content)
        # the render method expects this information
        info = {
          :registers        => { :site => site, :page => payload['page'] },
          :strict_filters   => liquid_options["strict_filters"],
          :strict_variables => liquid_options["strict_variables"],
        }
        page.content = template.render!(payload, info)

        Jekyll::TooltipGen.generate_tooltips(page, should_build_persistent_tooltips)
      end
    end
  end
end

Jekyll::Hooks.register [:pages, :documents], :post_convert do |page|

  should_build_tooltips = (ENV['JEKYLL_BUILD_TOOLTIPS'] == 'yes')
  should_build_persistent_tooltips = (ENV['JEKYLL_BUILD_PERSISTENT_TOOLTIPS'] == 'yes')

  if should_build_tooltips
    #puts "page: #{page.relative_path}"
    #Jekyll_TooltipGen_debug_page_info(page, true)

    markdown_extensions = page.site.config['markdown_ext'].split(',').map { |ext| ".#{ext.strip}" }
    next if false == markdown_extensions.include?(File.extname(page.relative_path)) && File.extname(page.relative_path) != ".html"
    next if false == Jekyll_TooltipGen_debug_filter_pages?(page)
    
    page_has_subtitle = (page.data["subtitle"] && false == page.data["subtitle"].empty?)
    page_has_description = (page.data["description"] && false == page.data["description"].empty?)
    next if false == page_has_subtitle && false == page_has_description

    Jekyll_TooltipGen_hack_description_out(page_has_subtitle, page_has_description, page, Jekyll_TooltipGen_desc_hack_separator)
    #puts ""
  end
end
