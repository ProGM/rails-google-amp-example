class AmpScrubber < Rails::Html::PermitScrubber
  TAG_MAPPINGS = {
    'img' => lambda { |node|
      if node['width'] && node['height']
        node.name = 'amp-img'
        node['layout'] = 'responsive'
        node['srcset'] = node['src']
      else
        node.remove
      end
    },
    'iframe' => lambda { |node|
      find_parent(node).add_child(node)

      node['src'] = node['src'].gsub(%r{^(\/\/|http:\/\/)}, 'https://')
      url = URI(node['src'])
      node['layout'] = 'responsive'

      if url.host.include?('youtube.com')
        node.name = 'amp-youtube'
        node['data-videoid'] = node['src'].match(%r{(\/embed\/|watch?v=)(.*)})[2]
        node.remove_attribute('src')
      else
        node.name = 'amp-iframe'
      end
    }
  }.freeze

  def initialize
    super
    @tags = %w(a em p span h1 h2 h3 h4 h5 h6 div strong s u br blockquote)
    @attributes = %w(style contenteditable frameborder allowfullscreen)
  end

  def self.find_parent(node)
    node = node.parent while node.parent
    node
  end

  protected

  def scrub_attribute?(name)
    !super
  end

  def scrub_node(node)
    if node.name.in?(TAG_MAPPINGS.keys)
      remap_node! node, TAG_MAPPINGS[node.name]
    else
      super
    end
  end

  def remap_node!(node, filter)
    case filter
    when String
      node.name = filter
    when Proc
      filter.call(node)
    end
  end
end
