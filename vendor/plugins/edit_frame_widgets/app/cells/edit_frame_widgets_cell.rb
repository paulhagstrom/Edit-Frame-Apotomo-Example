  
  class EditFrameWidgetsCell < Apotomo::StatefulWidget
    include Apotomo::EventAware
    helper_method :js_emit
    attr_accessor :record, :editing_mode, :filters, :filter, :hud_state, :message, :selected_id
    
    # If this widget has another of this type of widget in its detail panel, some things can be dealt with
    # automatically if they are listed here.  Format: {'author' => :author_id, 'publisher' => :publisher_id}
    # TODO: Maybe I can get it to actually use the models and associations, that would be better than hardwiring it.
    def child_panels
      {}
    end

    # The filters have the form key => {:name => 'Display Name', :conditions => conditions clause for find}
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

    # This loads the records in order to display the list, uses parameters set above
    def load_records(conditions = nil)
      find_params = {:conditions => conditions}
      find_params.merge!({:include => resources_include}) if resources_include
      find_params.merge!({:order => resources_default_order}) if resources_default_order
      @records = resource_model.find(:all, find_params)
    end
  
    # This should be a list of fields in the table that will be updated from the form fields
    # Format: [:title, :author_id, :publisher_id]
    def attributes_to_update
      []
    end
  
    # The set of things that reveal and hide themselves depending on demand.  Default is that all start and stay visible.
    # But if the detail panel starts hidden and should pop out, set, e.g., :detail => ['div_containing', false]
    def hud_panels
      {}
    end
    
    # These Javascript calls reveal and dismiss HUD panels.
    # They are collected together here in case something other than Prototype/Scriptalicious is desired
    def js_reveal(element = 'div_' + self.name, duration = 0.3, queue = nil)
      queue_parm = queue ? ", queue: {position: '" + queue + "', scope: '" + element + "'}" : ''
      "Effect.SlideDown('#{element}', {duration: #{duration}#{queue_parm}});"
    end

    def js_dismiss(element = 'div_' + self.name, duration = 0.3, queue = nil)
      queue_parm = queue ? ", queue: {position: '" + queue + "', scope: '" + element + "'}" : ''
      "Effect.SlideUp('#{element}', {duration: #{duration}#{queue_parm}});"
    end
  
    # These are the standard transitions, but you can add to them by calling
    # super.merge!({:other => [:transitions]}).
    def transition_map
      frame_transitions.merge(
      list_panel_transitions.merge(
      detail_panel_transitions.merge(
      filter_panel_transitions.merge(
      selected_panel_transitions.merge(
      message_panel_transitions
      )))))
    end
  
  
    # Containing frame states.
    
    def frame_transitions
      {
        :_frame_start => [:_frame],
        :_frame => [:_frame, :_frame_start],
      }
    end
  
    def _frame_start
      @editing_mode = false
      @hud_state = hud_panels
      jump_to_state :_frame
    end
  
    def _frame
      nil
    end
  
  
    # List panel states
    # The list panel displays a recordset based on the currently selected filter
  
    def list_panel_transitions
      {
        :_list_start => [:_list],
        :_list_reveal => [:_list],
        :_list_dismiss => [:_list],
        :_list => [:_list, :_list_start, :_list_reveal, :_list_dismiss],
      }
    end

    def _list_start
      jump_to_state :_list
    end
  
    def _list
      # Consult the filter panel to find what the current filter is, then load records accordingly
      filter_panel = parent[parent.name + '_filter']
      load_records(filter_panel.filters[filter_panel.filter][:conditions])
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
  
  
    # Selected panel states
    # The selected panel is a specialized display panel used within a detail panel of a parent.
    # When the parent calls load_record, the selected panel's :id_from_parent parameter is set.
    # When a select link is clicked on a subordinate list, this passes (as :id) to _selected_change
  
    def selected_panel_transitions
      {
        :_selected_start => [:_selected],
        :_selected_update => [:_selected],
        :_selected_change => [:_selected_update],
        :_selected => [:_selected, :_selected_start, :_selected_update, :_selected_change],
      }
    end

    def _selected_start
      @original = nil
      jump_to_state :_selected_update
    end
  
    def _selected
      @dirty = (@original && @original.id != @record.id)
      nil
    end
  
    def _selected_update
      load_record(@selected_id)
      @original ||= @record
      jump_to_state :_selected
    end
  
    def _selected_change
      @selected_id = param(:id)
      jump_to_state :_selected_update
    end
    
  
    # Filter panel states
    # The filter panel shows the filter options and current filter.
  
    def filter_panel_transitions
      {
        :_filter_start => [:_filter],
        :_filter_update => [:_filter],
        :_filter => [:_filter, :_filter_start, :_filter_update],
      }
    end
  
    def _filter_start
      @filters = filters_available
      @filter = filter_default
      jump_to_state :_filter
    end
  
    def _filter
      nil
    end
    
    def _filter_update
      @filter = param(:new_filter) || filter_default
      trigger(:filterChanged)
      jump_to_state :_filter
    end
  
    # Message panel states
    # The message panel is just for showing result messages in a way that doesn't rely on any other panel being visible.
    # The message is stored in the frame (using post_message below), and once displayed, it is erased.
  
    def message_panel_transitions
      {
        :_message_start => [:_message],
        :_message => [:_message, :message_start],
      }
    end

    def _message_start
      @message = ''
      jump_to_state :_message
    end
  
    def _message
      @message_to_display = @message
      @message = ''
      hud_reveal(:message, 0.3, 'front')
      hud_dismiss(:message, 1.0, 'end')
      nil
    end


    # Detail panel states
    # The detail panel is the most complicated one, it handles the bulk of the action here.
    # The frame holds the current id and whether we are in editing mode.
  
    def detail_panel_transitions
      {
        :_detail_start => [:_detail],
        :_show => [:_detail],
        :_edit => [:_detail],
        :_update => [:_detail_dismiss, :_show],
        :_new => [:_detail], 
        :_delete => [:_detail],
        :_detail_dismiss => [:_detail],
        :_detail => [:_detail, :_detail_start, :_show, :_edit, :_update, :_new, :_delete, :_detail_dismiss],
      }
    end
  
    def _detail_start
      new_record
      parent.editing_mode = false
      jump_to_state :_detail
    end
  
    def _detail
      @editing = parent.editing_mode
      nil
    end
  
    def _show
      load_record(param(:id))
      hud_reveal(:detail)
      parent.editing_mode = false
      show_child_panels
      jump_to_state :_detail
    end
  
    # Tell the child panels to move to their record matching the one specified by the just-shown parent
    def show_child_panels
      child_panels.each do |cp, field_id|
        parent[cp][cp + '_detail'].set_local_param(:id, @record[field_id])
        parent[cp][cp + '_detail'].trigger(:redraw)
        parent[cp][cp + '_detail'].trigger(:dismissList)
      end
    end
  
    def _edit
      load_record(parent.param(:id))
      hud_reveal(:detail)
      parent.editing_mode = true
      @return_to_show = parent.param(:from_show)
      edit_child_panels
      jump_to_state :_detail
    end
  
    def edit_child_panels  
      child_panels.keys.each do |cp|
        parent[cp][cp + '_detail'].trigger(:revealList)
        parent[cp][cp + '_detail'].trigger(:dismissPanel)
      end
    end
  
    def _update
      update_from_children
      @record.update_attributes(self.update_attributes_hash)
      @record.save
      @record.reload
      post_message "Changes saved."
      trigger(:recordChanged)
      jump_to_state :_show if @return_to_show
      jump_to_state :_detail_dismiss
    end

    # When an update occurs, we need to fetch the values from the children
    def update_from_children
      child_panels.each do |cp, field_id|
        @record[field_id] = self[cp + '_selected'].record.id
      end
    end
  
    def _new
      new_record
      hud_reveal(:detail)
      parent.editing_mode = true
      edit_child_panels
      jump_to_state :_detail
    end
  
    def _delete
      if (doomed = find_record(parent.param(:id)))
        if doomed.id == @record.id
          new_record
          hud_dismiss(:detail)
        end
        doomed.destroy
        post_message "Record deleted."
        trigger(:recordChanged)
      end
      jump_to_state :_detail
    end

    def _detail_dismiss
      hud_dismiss(:detail)
      jump_to_state :_detail
    end
    
  
    # Other helpers
  
    def find_record(id = nil)
      resource_model.find_by_id(id)
    end
  
    def load_record(id = nil)
      if @record = find_record(id)
        load_child_selected_records
      else
        new_record
      end
    end

    def load_child_selected_records
      child_panels.each do |cp, id_field|
        self[cp + '_selected'].selected_id = @record[id_field]
      end
    end

    def new_record
      @record = resource_model.new
      load_child_selected_records
    end
  
    def update_attributes_hash
      attrs = {}
      self.attributes_to_update.each do |att|
        attrs[att] = param(att)
      end
      attrs
    end

    def resource_model
      Object.const_get param(:resource).classify
    end
    
    def js_emit
      js_emit = @js_emit || ''
      @js_emit = ''
      js_emit
    end

    def set_js_emit(to_emit)
      set_local_param(:js_emit, (local_param(:js_emit) || '') + to_emit)
    end
  
    def get_js_emit
      js_emit = local_param(:js_emit)
      set_local_param(:js_emit, nil)
      js_emit
    end

    def post_message(message = '')
      parent[parent.name + '_message'].message = message
      trigger(:messagePosted)
    end
    
    # The HUD reveal and dismiss helpers will set up Javascript to hide or reveal certain panels.
    # The state of each panel is remembered, so that re-revealing or re-dismissing won't do anything.
    # The frame keeps track of the state of each panel, and they are assumed to be called by the child panels.
    # If there is no entry for the panel in the HUD array, it will also do nothing.
  
    def hud_reveal(panel, duration = 0.3, queue = nil)
      hud_control(panel, false, duration, queue)
    end

    def hud_dismiss(panel, duration = 0.3, queue = nil)
      hud_control(panel, true, duration, queue)
    end
    
    def hud_control(panel, dismiss = false, duration = 0.3, queue = nil)
      @js_emit ||= ''
      if hud = parent.hud_state[panel]
        if hud[1] == dismiss
          @js_emit = @js_emit + (dismiss ? js_dismiss(hud[0], duration, queue) : js_reveal(hud[0], duration, queue))
          hud[1] = !dismiss
          parent.hud_state.merge!({panel => hud})
        end
      end
    end
  end
  

