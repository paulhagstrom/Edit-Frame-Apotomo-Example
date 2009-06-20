class BooksCell < EditFrameCell

  def filters_available
    super.merge!({
      'ns' => {:name => 'Titles after H', :conditions => ["title > 'H'"]},
    })
  end
  
  def resources_include
    [:author, :publisher]
  end
  
  def resources_default_order
    'authors.name, books.title'
  end
  
  def attributes_to_update
    [:title]
    # [:title, :author_id, :publisher_id]
  end
      
  def hud_panels
    {
      :detail => ['div_book_detail_panels', false],
    }
  end  
  
  def show_post
    parent['author']['author_detail'].set_local_param(:id_from_parent, @record.author.id)
    parent['publisher']['publisher_detail'].set_local_param(:id_from_parent, @record.publisher.id)
    parent['author']['author_detail'].trigger(:dismissList)
    parent['publisher']['publisher_detail'].trigger(:dismissList)
    trigger(:parentShow)
  end
  
  def edit_post
    parent['author']['author_detail'].trigger(:revealList)
    parent['author']['author_detail'].trigger(:dismissPanel)
    parent['publisher']['publisher_detail'].trigger(:revealList)
    parent['publisher']['publisher_detail'].trigger(:dismissPanel)
    # trigger(:parentShow)
  end
  
  # Load record for the parent triggers loading of the appropriate records for the children as well
  def load_record(id_param = :id, load_children = true)
    record = super(id_param)
    if load_children
      parent.set_child_param('author_selected', :id_from_parent, record.author_id)
      parent.set_child_param('publisher_selected', :id_from_parent, record.publisher_id)
      trigger(:loadChildRecords)
    end
    record
  end
  
  # This seems pretty redundant with load_record to me.
  def new_record
    record = super
    parent.set_child_param('author_selected', :id_from_parent, -1)
    parent.set_child_param('publisher_selected', :id_from_parent, -1)
    trigger(:loadChildRecords)
    record
  end
  
  # When an update occurs, we need to fetch the values from the children
  def _update
    author_id = self['author_selected'].selected.id
    publisher_id = self['publisher_selected'].selected.id
    @record.author = Author.find_by_id(author_id) if author_id
    @record.publisher = Publisher.find_by_id(publisher_id) if publisher_id
    super
  end
    
end
