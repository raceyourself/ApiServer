module ApiDocsHelper

  def accessible_applications(&block)
    relation = Doorkeeper::Application
    relation.all.each { |app| block.call app if block_given? }
  end

end