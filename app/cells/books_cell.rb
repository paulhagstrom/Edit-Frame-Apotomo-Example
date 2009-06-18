class BooksCell < CommonCell

  def transition_map
    super.merge!({
      :_author_select => [:_detail],
      :_publisher_select => [:_detail],
      :_detail => super[:_detail] + [:_author_select, :_publisher_select]
    })    
  end

  def filters_available
    super.merge!({
      'ns' => {:name => 'Titles after H', :conditions => ["title > 'H'"]},
    })
  end
  
  def attributes_to_update
    [:title, :author_id, :publisher_id]
  end
      
  def resources_include
    [:author, :publisher]
  end
    
  def hud_panels
    {:detail => ['div_book_detail_panels', false]}
  end
  
  # Show the record, but alert the frame that we need to send the author and publisher
  # frames into the show state for the values in this record
  # YOU ARE HERE
  def _show
    parent.set_child_param('author_frame', :id, @record.author_id)
    parent.set_child_param('publisher_frame', :id, @record.publisher_id)
    trigger(:bookShown)
    # if @editing
      # parent.find_by_id('author_detail').invoke(:_edit)
      # parent.find_by_id('author_list').invoke(:_list_select)
      # parent.find_by_id('publisher_detail').invoke(:_edit)
      # parent.find_by_id('publisher_list').invoke(:_list_select)
    # else
    parent.find_by_id('author_detail').invoke(:_show)
    parent.find_by_id('author_list').invoke(:_list_dismiss)
    parent.find_by_id('publisher_detail').invoke(:_show)
    parent.find_by_id('publisher_list').invoke(:_list_dismiss)
    # end
    parent.set_child_param('author_frame', :id, nil)
    parent.set_child_param('publisher_frame', :id, nil)
    super
  end
  
  # send the proper values off to the subordinates
  def _detail
    super
    # parent.set_child_param('author_detail', :id, @record.author_id)
    # parent.set_child_param('publisher_detail', :id, @record.publisher_id)
    # if @editing
    #   parent.find_by_id('author_detail').invoke(:_edit)
    #   parent.find_by_id('author_list').invoke(:_list_select)
    #   parent.find_by_id('publisher_detail').invoke(:_edit)
    #   parent.find_by_id('publisher_list').invoke(:_list_select)
    # end
    # trigger(:showChildren)
    nil
  end
      
  # extensions for selecting (frame gets it, and it is injected into detail)
  
  # def _author_select
  #   detail = root.find_by_id('book_detail')
  #   detail.record[:author_id] = param(:author_id)
  #   detail.trigger(:viewChanged)
  #   # @record[:author_id] = param(:author_id)
  #   jump_to_state :_detail
  # end
  # 
  # def _publisher_select
  #   root.find_by_id('book_detail').record[:publisher_id] = param(:publisher_id)
  #   trigger(:viewChanged)
  #   # @record[:publisher_id] = param(:publisher_id)
  #   jump_to_state :_detail
  # end
end
