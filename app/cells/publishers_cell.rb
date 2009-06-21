class PublishersCell < EditFrameWidgetsCell
  
  def filters_available
    super.merge({
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
    super.merge({
      :list => ['div_publisher_list_panels', true],
      :detail => ['div_publisher_detail', false],
      :message => ['div_publisher_message', false],
    })
  end
  
end
