class <%= class_name %>Cell < EditFrameWidgetsCell

  def filters_available
    super.merge({
      #'ns' => {:name => 'Titles after H', :conditions => ["title > 'H'"]},
    })
  end
  
  def resources_default_order
    #'authors.name, books.title'
    nil
  end
  
  def attributes_to_update
    #[:title]
    nil
  end

  def child_panels
    #{'author' => :author_id, 'publisher' => :publisher_id}
    nil
  end
  
  def resources_include
    #[:author, :publisher]
    nil
  end
  
  def hud_panels
    super.merge({
      # :detail => ['div_book_detail_panels', false],
      # :message => ['div_book_message', false],
    })
  end  
    
end
