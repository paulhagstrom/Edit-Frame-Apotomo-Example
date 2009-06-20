class PublishersCell < EditFrameCell
    
  def transition_map
    super.merge!({
      :_change => [:_detail],
      :_detail => super[:_detail] + [:_change],
    })    
  end

  def filters_available
    super.merge!({
      'nk' => {:name => 'Publishers after K', :conditions => ["name > 'K'"]}
    })
  end

  def resources_default_order
    'publishers.name'
  end

  def attributes_to_update
    [:name]
  end

  def hud_panels
    {
      :list => ['div_publisher_list_panels', true],
      :detail => ['div_publisher_detail', false],
    }
  end

  def _parent_changed
    super('publisher_filter')
  end
  
end
