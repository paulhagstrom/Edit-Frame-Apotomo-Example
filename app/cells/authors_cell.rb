class AuthorsCell < CommonCell
  
  def transition_map
    super.merge!({
      :_chosen => [:_list],
      :_list => super[:_list] + [:_chosen]
    })    
  end

  def filters_available
    super.merge!({
      'ns' => {:name => 'Authors after H', :conditions => ["name > 'H'"]}
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
    {:list => ['div_author_list_panels', false]}
  end

  def _chosen
    detail = parent.parent.root.find_by_id('book_detail')
    detail.record[:author_id] = param(:author_id)
    puts "Found " + param(:author_id)
    detail.trigger(:viewChanged)
    jump_to_state :_list
  end
  
end
