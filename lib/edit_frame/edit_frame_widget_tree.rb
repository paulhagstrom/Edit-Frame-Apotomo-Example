# module EditFrame::EditFrameWidgetTree
#     
#   # This embeds a child_frame as a child of the parent_frame, and wires them together
#   def embed_frame(parent_frame, child_frame)
#     parent_detail = parent_frame.name + '_detail'
#     parent_list = parent_frame.name + '_list'
#     child_detail = child_frame.name + '_detail'
#     child_list = child_frame.name + '_list'
#     child_selected = child_frame.name + '_selected'
#     child_resource = child_frame.param(:resource)
#     child_cell_class = child_resource.pluralize.to_sym
#     
#     # embed the primary child frame under as a child of the parent frame
#     parent_frame << child_frame
#     # embed the selected panel under the parent's detail panel
#     parent_frame[parent_detail] << cell(child_cell_class, :_selected_start, child_selected, :resource => child_resource)
#     # Handle selections
#     parent_frame.watch(:recordChanged, child_selected, :_selected_update, child_detail)
#     parent_frame.watch(:recordChanged, parent_list, :_list, child_detail)
#     parent_frame.watch(:selectClick, child_selected, :_selected_change, child_list)
#     child_frame[child_detail].watch(:redraw, child_detail, :_show)
#     return parent_frame
#   end
#   
#   # This is a semi-generic frame/filter/list/detail widget
#   # It should be fully functional for anything that doesn't need to communicate outside.
#   # The required resource is the model.
#   # The naming of the cell generally tracks this, though it can be overridden using :cell_sym = :other_kind_of_cell
#   # There is a provision of a prefix for the name, in case it is useful when there are many on a screen.
#   def draw_list_detail_filter_frame(resource, opts = {})
#     opts[:cell_sym] ||= resource.pluralize.to_sym
#     opts[:prefix] ||= ''
#     base_name = opts[:prefix] + resource
#     frame = cell(opts[:cell_sym], :_frame_start, base_name, :resource => resource)
#       # Insert frame, list, detail, and message as children of the frame
#       frame << message = cell(opts[:cell_sym], :_message_start, base_name + '_message')
#       frame << filter = cell(opts[:cell_sym], :_filter_start, base_name + '_filter')
#       frame << list = cell(opts[:cell_sym], :_list_start, base_name + '_list')
#       frame << detail = cell(opts[:cell_sym], :_detail_start, base_name + '_detail')
#       # Wire up the communication between panels.
#       frame.watch(:editClick, detail.name, :_edit, list.name)
#       frame.watch(:showClick, detail.name, :_show, list.name)
#       frame.watch(:delClick, detail.name, :_delete, list.name)
#       frame.watch(:editClick, detail.name, :_edit, detail.name)
#       frame.watch(:revealList, list.name, :_list_reveal, detail.name)
#       frame.watch(:dismissList, list.name, :_list_dismiss, detail.name)
#       frame.watch(:dismissPanel, detail.name, :_detail_dismiss, detail.name)
#       frame.watch(:recordChanged, list.name, :_list, detail.name)
#       frame.watch(:newClick, detail.name, :_new, filter.name)
#       frame.watch(:filterClick, filter.name, :_filter_update, filter.name)
#       frame.watch(:filterChanged, list.name, :_list, filter.name)
#       frame.watch(:messagePosted, message.name, :_message, nil)
#     return frame
#   end
# 
# end
# 
