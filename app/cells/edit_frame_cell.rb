class EditFrameCell < Apotomo::StatefulWidget
  include Apotomo::EventAware
  helper_method :js_emit, :msg_emit
  attr_accessor :record, :selected

  # TODO: I think basically what's left is to clean this up, get rid of comments and obsolescences.
  # TODO: Also, I should maybe try to make it prettier.
  # But I think it is essentially ready to be embedded in caslx so I can see what else I need to be able to do.
  # TODO: Actually, I should expire the messages.  Perhaps I can make them fade.  But I see when I bring back up
  # the edit HUD that the previous message is still there.  The messages can maybe be improved.
  # TODO: There might also be a bit of factoring I can do to try to simplify the children.
  
  # These things at the top are what you would be most likely to want to add to in subclasses.
  
  # The filters have the form key => {:name => 'Display Name', :conditions => conditions clause for find}
  # In the subclass, if you want to keep the 'All' filter, you can do the following
  # def filters_available
  #   super.merge!({
  #     'ns' => {:name => 'Titles after H', :conditions => ["title > 'H'"]},
  #   })
  # end
  def filters_available
    {
      'all' => {:name => 'All', :conditions => nil},
    }
  end
  
  # The filter default is the key of the filter to use if none has been specifically selected
  def filter_default
    'all'
  end

  # This is the :include parameter for the find that loads the recordset if using load_records below
  # If you have related subtables of author and publisher, for example, then you can do this:
  # def resources_include
  #   [:author, :publisher]
  # end
  def resources_include
    nil
  end
  
  # This is the :order parameter for the find that loads the recordset if using load_records below
  # def resources_default_order
  #   'authors.name, books.title'
  # end
  def resources_default_order
    nil
  end

  # This should be a list of fields in the table that will be updated from the form fields
  # def attributes_to_update
  #   [:title, :author_id, :publisher_id]
  # end
  def attributes_to_update
    [:name]
  end
  
  # This is called in order to display the list.
  # If something fancier is needed, this can be redefined (and then resources_include,
  # resources_default_order will no longer be needed)
  def load_records(conditions = nil)
    find_params = {:conditions => conditions}
    find_params.merge!({:include => resources_include}) if resources_include
    find_params.merge!({:order => resources_default_order}) if resources_default_order
    @records = resource_model.find(:all, find_params)
  end
  
  # The set of things that reveal and hide themselves depending on demand.  Default is that all start and stay visible.
  # But if the detail panel starts hidden and should pop out, set, e.g., :detail => ['div_containing', false]
  def hud_panels
    {}
  end
  
  # These Javascript calls reveal and dismiss HUD panels.
  # They are collected together here in case something other than Prototype/Scriptalicious is desired
  def js_reveal(element = 'div_' + self.name)
    "Effect.SlideDown('#{element}', {duration: 0.3});"
  end

  def js_dismiss(element = 'div_' + self.name)
    "Effect.SlideUp('#{element}', {duration: 0.3});"
  end
  
  # These are the standard transitions, but you can add to them by calling
  # super.merge!({:other => [:transitions]}).
  def transition_map
    { :_frame_start => [:_frame],
      :_list_start => [:_list],
      :_list_select => [:_list],
      :_list_dismiss => [:_list],
      :_list => [:_list, :_list_start, :_list_reveal, :_list_dismiss],
      :_detail_start => [:_detail],
      :_delete => [:_detail],
      :_edit => [:_detail],
      :_show => [:_show_common],
      :_show_from_parent => [:_show_common],
      :_show_common => [:_detail],
      :_new => [:_detail], 
      :_update => [:_detail, :_show],
      :_detail_dismiss => [:_detail],
      :_parent_changed => [:_detail],
      :_select => [:_detail],
      :_detail => [:_detail, :_detail_start, :_edit, :_edit_direct, :_update, :_delete, :_new, :_show, :_show_from_parent,
          :_detail_dismiss, :_parent_changed, :_select],
      :_filter_start => [:_filter],
      :_filter_update => [:_filter],
      :_filter => [:_filter, :_filter_start, :_filter_update],
      :_selected_start => [:_selected],
      :_selected_update => [:_selected],
      :_selected_change => [:_selected],
      :_selected => [:_selected, :_selected_update, :_selected_change],
      :_message_start => [:_message],
      :_message => [:_message]
    }
  end
  
  
  # Containing frame states.
  
  # frame_start makes filters_available, the resource, and the current filter available to all children
  # The frame also keeps track of whether we are in edit mode or show mode
  def _frame_start
    set_local_param(:filters_available, self.filters_available)
    set_local_param(:current_filter, self.filter_default)
    set_local_param(:hud_panels, hud_panels)
    set_local_param(:editing, 'n')
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
    load_records(param(:filters_available)[param(:current_filter)][:conditions])
    nil
  end
  
  def _list_reveal
    hud_reveal(:list)
    jump_to_state :_list
  end

  def _list_dismiss
    hud_dismiss(:list)
    jump_to_state :_list
  end
  
  
  # Detail panel states
  # If param(:id) is set, it will show detail/editing for record :id
  # The frame knows if we're editing (parent.param(:editing))
  
  def _detail_start
    @record = new_record
    parent.set_local_param(:current_id, -1)
    parent.set_local_param(:editing, 'n')
    @editing = false
    jump_to_state :_detail
  end
  
  def _show_from_parent
    @record = load_record(param(:id_from_parent))
    jump_to_state :_show_common
  end
  
  def _show
    @record = load_record(param(:id))
    jump_to_state :_show_common
  end
  
  def show_post
  end
    
  def _show_common
    parent.set_local_param(:current_id, @record.id)
    hud_reveal(:detail)
    parent.set_local_param(:editing, 'n')
    show_post
    jump_to_state :_detail
  end
  
  def _edit
    @record = load_record(param(:id))
    parent.set_local_param(:current_id, @record.id)
    hud_reveal(:detail)
    parent.set_local_param(:direct, 'n')
    parent.set_local_param(:editing, 'y')
    edit_post
    jump_to_state :_detail
  end

  def _edit_direct
    parent.set_local_param(:direct, 'y')
    parent.set_local_param(:editing, 'y')
    edit_post
    jump_to_state :_detail
  end
  
  def edit_post  
  end
  
  def _new
    @record = new_record
    parent.set_local_param(:current_id, -1)
    hud_reveal(:detail)
    parent.set_local_param(:editing, 'y')
    jump_to_state :_detail
  end
  
  def _delete
    unless (@doomed = load_record(param(:id), false)).id.nil?
      @doomed.destroy
      # @msg = "Record deleted."
      post_message "Record deleted."
      trigger(:recordChanged)
    end
    jump_to_state :_detail
  end

  def _detail
    @editing = (parent.param(:editing) == 'y')
    nil
  end
    
  def _update
    @record.update_attributes(self.update_attributes_hash)
    @record.save
    @record.reload
    post_message "Changes saved."
    # @msg = "Changes saved."
    trigger(:recordChanged)
    if parent.param(:direct) == 'n'
      hud_dismiss(:detail)
      jump_to_state :_detail
    else
      jump_to_state :_show
    end
  end
  
  def _detail_dismiss
    hud_dismiss(:detail)
    jump_to_state :_detail
  end
    
  
  # Selected panel states
  
  def _selected_start
    id_from_parent = param(:id_from_parent)
    @selected = load_record(id_from_parent)
    jump_to_state :_selected
  end
  
  def _selected
    nil
  end
  
  def _selected_update
    id_from_parent = param(:id_from_parent)
    @selected = load_record(id_from_parent)
    jump_to_state :_selected
  end
  
  def _selected_change
    id = param(:id)
    @selected = load_record(id)
    jump_to_state :_selected
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
  
  
  # Message panel states
  
  def _message_start
    jump_to_state :_message
  end
  
  def _message
    @message = parent.param(:message)
    parent.set_local_param(:message, nil)
    nil
  end
  
  # Other helpers
  
  def resource_model
    Object.const_get param(:resource).classify
  end
  
  # def find_child(root, widget_id)
  #   root.children.find_all do |w|
  #     return w if w.name.to_s == widget_id.to_s
  #   end
  #   nil
  # end
  
  def js_emit
    js_emit = @js_emit || ''
    @js_emit = ''
    js_emit
  end

  def post_message(message = '')
    parent.set_local_param(:message, message)
    trigger(:postMessage)
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
    @js_emit ||= ''
    if hud = param(:hud_panels)[panel]
      unless hud[1]
        @js_emit = @js_emit + js_reveal(hud[0])
        hud[1] = true
        parent.set_local_param(:hud_panels, param(:hud_panels).merge!({panel => hud}))
      end
    end
  end
  
  def hud_dismiss(panel)
    @js_emit ||= ''
    if hud = param(:hud_panels)[panel]
      if hud[1]
        @js_emit = @js_emit + js_dismiss(hud[0])
        hud[1] = false
        parent.set_local_param(:hud_panels, param(:hud_panels).merge!({panel => hud}))
      end
    end
  end
  
  def load_record(id = nil, load_children = true)
    resource_model.find_by_id(id) || resource_model.new
  end

  def new_record
    resource_model.new
  end
  
  def update_attributes_hash
    attrs = {}
    self.attributes_to_update.each do |att|
      attrs[att] = param(att)
    end
    attrs
  end
  
end


