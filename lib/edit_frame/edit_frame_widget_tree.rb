module EditFrame::EditFrameWidgetTree
  
  # The way this is supposed to work is like this:
  # The basic edit/filter/list thing looks like this:
  # resource
  #   detail
  #   filter
  #   list
  # Now, suppose you want to embed something as a lookup for the detail of the parent
  # You want a selected panel within the resource detail frame,
  # but you want the rest of the lookup panels as children of resource.
  # Like:
  # resource
  #   detail
  #     resource2_selected
  #   filter
  #   list
  #   resource2
  #     detail
  #     filter
  #     list
  # The resource and resource2 frames keep track of important information
  # So, resource knows what its current record is, and resource2 knows its.
  # resource2_selected has to go to parent.parent.find_by_id('resource2').param(:current_id).
  # actually, the resource2_selection and the resource2 frame are pretty much independent.
  # They might communicate, but they can be revealing different things, they need to have different current records.
  
  # This embeds a child_frame as a child of the parent_frame, and wires them together
  def embed_frame(parent_frame, child_frame)
    # embed the primary child frame under as a child of the parent frame
    parent_frame << child_frame
    # embed the selected panel under the parent's detail panel
    parent_frame[parent_frame.name + '_detail'] <<
      cell(child_frame.param(:resource).pluralize.to_sym, :_selected_start, child_frame.name + '_selected')
    # Handle selections
    parent_frame.watch(:selectClick, child_frame.name + '_selected', :_selected_change, child_frame.name + '_list')
    return parent_frame
  end
  
  # This is a semi-generic frame/filter/list/detail widget
  # It should be fully functional for anything that doesn't need to communicate outside.
  # The required resource is the model.
  # The naming of the cell generally tracks this, though it can be overridden using :cell_sym = :other_kind_of_cell
  # There is a provision of a prefix for the name, in case it is useful when there are many on a screen.
  def draw_list_detail_filter_frame(resource, opts = {})
    opts[:cell_sym] ||= resource.pluralize.to_sym
    opts[:prefix] ||= ''
    base_name = opts[:prefix] + resource
    frame = cell(opts[:cell_sym], :_frame_start, base_name, :resource => resource)
      # Insert frame, list, and detail as children of the frame
      frame << message = cell(opts[:cell_sym], :_message_start, base_name + '_message')
      frame << filter = cell(opts[:cell_sym], :_filter_start, base_name + '_filter')
      frame << list = cell(opts[:cell_sym], :_list_start, base_name + '_list')
      frame << detail = cell(opts[:cell_sym], :_detail_start, base_name + '_detail')
      # Wire up the communication between panels.
      frame.watch(:editClick, detail.name, :_edit, list.name)
      frame.watch(:showClick, detail.name, :_show, list.name)
      frame.watch(:delClick, detail.name, :_delete, list.name)
      frame.watch(:editClick, detail.name, :_edit_direct, detail.name)
      frame.watch(:revealList, list.name, :_list_reveal, detail.name)
      frame.watch(:dismissList, list.name, :_list_dismiss, detail.name)
      frame.watch(:dismissPanel, detail.name, :_detail_dismiss, detail.name)
      frame.watch(:recordChanged, list.name, :_list, detail.name)
      frame.watch(:newClick, detail.name, :_new, filter.name)
      frame.watch(:filterClick, filter.name, :_filter_update, filter.name)
      frame.watch(:filterChanged, list.name, :_list, filter.name)
      frame.watch(:postMessage, message.name, :_message, nil)
    return frame
  end

end

