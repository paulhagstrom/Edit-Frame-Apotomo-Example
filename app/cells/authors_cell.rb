class AuthorsCell < EditFrameWidgetsCell
  
  def filters_available
    super.merge({
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
    super.merge({
      :list => ['div_author_list_panels', true],
      :detail => ['div_author_detail', false],
      :message => ['div_author_message', false],
    })
  end
    
end
