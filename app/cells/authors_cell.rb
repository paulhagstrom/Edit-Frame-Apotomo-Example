class AuthorsCell < EditFrameCell
  
  def transition_map
    super.merge!({
      :_change => [:_detail],
      :_detail => super[:_detail] + [:_change],
    })    
  end

  def filters_available
    super.merge!({
      'ns' => {:name => 'Authors after H', :conditions => ["name > 'H'"]}
    })
  end

  def resources_default_order
    'authors.name'
  end

  def attributes_to_update
    [:name]
  end

  def hud_panels
    {
      :list => ['div_author_list_panels', true],
      :detail => ['div_author_detail', false],
    }
  end

  def _parent_changed
    super('author_filter')
  end
    
end
