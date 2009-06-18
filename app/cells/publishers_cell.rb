class PublishersCell < CommonCell
    
  def transition_map
    super.merge!({
      :_chosen => [:_list],
      :_list => super[:_list] + [:_chosen]
    })    
  end

  def filters_available
    super.merge!({
      'nk' => {:name => 'Publishers after K', :conditions => ["name > 'K'"]}
    })
  end

  # def list
  #   @conditions = param(:available_filters)[param(:current_filter)][:conditions]
  #   @records = resource_model.find(:all, #:include => [:author, :publisher],
  #     :conditions => param(:available_filters)[param(:current_filter)][:conditions])
  #   nil
  # end

  def attributes_to_update
    [:name]
  end

  def hud_panels
    {:list => ['div_publisher_list_panels', false]}
  end

  def _chosen
    detail = parent.parent.root.find_by_id('book_detail')
    detail.record[:publisher_id] = param(:publisher_id)
    detail.trigger(:viewChanged)
    jump_to_state :_list
  end

end
