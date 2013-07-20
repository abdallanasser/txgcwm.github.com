# Modified by KenJ(@denjones) 2012-3-20
# Add Unicode support to the category
# See category_generator.rb
#
# place this file in your plugins directory and add the tag to your sidebar
#$ cat source/_includes/asides/categories.html
#<section>
# <h1>Categories</h1>
# <ul id="categories">
# {% category_list %}
# </ul>
#</section>

require 'stringex'

module Jekyll
  class CategoryListTag < Liquid::Tag
    def render(context)
      html = ""
      categories = context.registers[:site].categories.keys
	  category_dir = context.registers[:site].config['category_dir']
      categories.sort.each do |category|
        posts_in_category = context.registers[:site].categories[category].size	
        category_url = File.join(category_dir, category.gsub(/_|\P{Word}/u, '-').gsub(/-{2,}/u, '-').to_url.downcase)
        html << "<li class='category'><a href='/#{category_url}/'>#{category} (#{posts_in_category})</a></li>\n"
      end
      html
    end
  end
end

Liquid::Template.register_tag('category_list', Jekyll::CategoryListTag)
