class CommonCell < Apotomo::StatefulWidget
  include Apotomo::EventAware
  helper_method :js_emit, :msg_emit
  attr_accessor :record

  # Current state: Communication is not working so well.
  # TODO: Get selection from child lists working.  It is doing nothing right at the moment.
  # I think I need to look into how watch works, and where the events bubble to.
  # I tried watching from the author/publisher frames, but it didn't seem to be making the transitions right.
  # I maybe should add update_author and update_publisher methods to book, and have author_list (or whatever) call them.
  # I'd also like to deal with these visibility issues, making things appear and disappear when they should.
  #
  # These things at the top are what you would be most likely to want to replace in subclasses.
  
  def filters_available
    {
      'all' => {:name => 'All', :conditions => nil},
    }
  end
  
  def filter_default
    'all'
  end

  # This is the :include parameter for the find that loads the recordset
  def resources_include
    nil
  end
  
  # This is the :order parameter for the find that loads the recordset
  def resources_default_order
    nil
  end

  # This should be a list of fields in the table that will be updated from the form fields
  def attributes_to_update
    [:name]
  end
  
  # If you need something fancier, this can be replaced instead of the
  # resources_include, resources_default_order above
  def resources_load(conditions = nil)
    find_params = {:conditions => conditions}
    find_params.merge({:include => resources_include}) if resources_include
    find_params.merge({:order => resources_default_order}) if resources_default_order
    @records = resource_model.find(:all, find_params)
  end
  
  # These are the standard transitions, but you can add to them by calling
  # super.merge!({:other => [:transitions]}).
  def transition_map
    { :_frame_start => [:_frame],
      :_frame => [:_filter_update, :_frame],
      :_list_start => [:_list],
      :_list_select => [:_list],
      :_list => [:_list, :_list_start, :_list_select, :_list_dismiss],
      :_list_dismiss => [:_list],
      :_detail_start => [:_show],
      :_edit => [:_detail],
      :_show => [:_detail],
      :_new => [:_detail], 
      :_update => [:_detail],
      :_delete => [:_detail_start],
      :_detail => [:_detail, :_detail_start, :_edit, :_update, :_delete, :_new, :_show, :_detail_dismiss],
      :_detail_dismiss => [:_detail],
      :_filter_start => [:_filter],
      :_filter_update => [:_filter],
      :_filter => [:_filter_start, :_filter_update, :_filter],
    }
  end

  # The set of things that reveal and hide themselves depending on demand.  Default is that all start and stay visible.
  # But if the detail panel starts hidden and should pop out, set, e.g., :detail => ['div_containing', false]
  def hud_panels
    {}
  end
  
  # The Javascript calls are collected together here in case something other than Prototype/Scriptalicious is desired
  def js_reveal(element = 'div_' + self.name)
    "Effect.SlideDown('#{element}', {duration: 0.3});"
  end

  def js_dismiss(element = 'div_' + self.name)
    "Effect.SlideUp('#{element}', {duration: 0.3});"
  end
  
  
  # Containing frame states.
  
  # frame_start makes filters_available, the resource, and the current filter available to all children
  def _frame_start
    # set_local_param(:resource, self.opts[:resource])
    set_local_param(:filters_available, self.filters_available)
    set_local_param(:current_filter, self.filter_default)
    set_local_param(:hud_panels, hud_panels)
    jump_to_state :_frame
  end
  
  def _frame
    nil
  end
  
  
  # List panel states
  
  def _list_start
    jump_to_state :_list
  end
  
  def _list
    resources_load(param(:filters_available)[param(:current_filter)][:conditions])
    nil
  end
  
  def _list_select
    hud_reveal(:list)
    jump_to_state :_list
  end

  def _list_dismiss
    hud_dismiss(:list)
    jump_to_state :_list
  end
  
  
  # Detail panel states
  # If param(:id) is set, it will show detail/editing for record :id
  
  def _detail_start
    @editing = false
    jump_to_state :_detail
  end
  
  def _show
    hud_reveal(:detail)
    @editing = false
    set_local_param(:id, nil)
    jump_to_state :_detail
  end

  def _edit
    hud_reveal(:detail)
    @editing = true
    set_local_param(:id, nil)
    jump_to_state :_detail
  end

  def _new
    hud_reveal(:detail)
    @editing = true
    set_local_param(:id, 0)
    jump_to_state :_detail
  end
  
  def _delete
    unless (@record = load_record).id.nil?
      @record.destroy
      @msg = "Record deleted."
      trigger(:recordChanged)
    end
    jump_to_state :_detail_start
  end

  def _detail
    @record = load_record
    nil
  end
      
  # transitions to update from edit, so @record should still exist
  def _update
    @record.update_attributes(self.update_attributes_hash)
    @record.save
    @record.reload
    @msg = "Changes saved."
    trigger(:recordChanged)
    jump_to_state :_detail
  end
  
  def _detail_dismiss
    hud_dismiss(:detail)
    jump_to_state :_detail
  end
  
  
  # Filter panel states
  
  def _filter_start
    jump_to_state :_filter
  end
  
  def _filter
    @filters_available = param(:filters_available)
    @current_filter = param(:current_filter)
    nil
  end
    
  def _filter_update
    parent.set_local_param(:current_filter, param(:new_filter) || self.filter_default)
    trigger(:filterChanged)
    jump_to_state :_filter
  end
  
  
  # Other helpers
  
  def resource_model
    Object.const_get param(:resource).classify
  end
  
  def find_child(root, widget_id)
    root.children.find_all do |w|
      return w if w.name.to_s == widget_id.to_s
    end
    nil
  end
  
  def js_emit
    js_emit = @js_emit || ''
    @js_emit = ''
    js_emit
  end

  def msg_emit
    msg_emit = @msg || ''
    @msg = ''
    msg_emit
  end
  
  def set_js_emit(to_emit)
    set_local_param(:js_emit, (local_param(:js_emit) || '') + to_emit)
  end
  
  def get_js_emit
    js_emit = local_param(:js_emit)
    set_local_param(:js_emit, nil)
    js_emit
  end
  
  def hud_reveal(panel)
    if hud = param(:hud_panels)[panel]
      unless hud[1]
        @js_emit = js_reveal(hud[0])
        hud[1] = true
        parent.set_local_param(:hud_panels, param(:hud_panels).merge!({panel => hud}))
      end
    end
  end
  
  def hud_dismiss(panel)
    if hud = param(:hud_panels)[panel]
      if hud[1]
        @js_emit = js_dismiss(hud[0])
        hud[1] = false
        parent.set_local_param(:hud_panels, param(:hud_panels).merge!({panel => hud}))
      end
    end
  end
  
  def load_record(id_param = :id)
    record = resource_model.find_by_id(param(id_param)) || resource_model.new
  end

  def update_attributes_hash
    attrs = {}
    self.attributes_to_update.each do |att|
      attrs[att] = param(att)
    end
    attrs
  end
  
  
  # Patch attempt: try to allow for css visibility, so I can use effects.  Didn't work.  Commenting it out.
  # Problem seems to be that visible! plus jump_to_state doesn't actually remember the visibility value.
  # The AJAX replacement is not inner_html, and so it repeats the display:none style despite the attempt
  # to make it visible.  Solution for now is to add my own divs in the views and make them visible and invisible separately.
  # Which also doesn't seem to be possible; I need to get the emitted javascript added to the page.

  # Set children_to_render to ALL, we'll react to visibility in the div style
  # Was:
  # def children_to_render
  #   children.find_all do |w|
  #     w.visible?
  #   end
  # end
  # Replaced with:
  # def children_to_render
  #   children
  # end
  
  # Wrap the widget's current state content into a div frame.
  # Added the visibility style.  Later maybe allow for more sophisticated css classing?
  # Was:
  # def frame_content(content)
  #   '<div id="' + name.to_s + '">'+content+"</div>"
  # end
  # Replaced with:
  # def frame_content(content)
  #   '<div id="' + name.to_s + '" style="display:' + (@visible ? 'block' : 'none') + ';">'+content+"</div>"
  # end

end


