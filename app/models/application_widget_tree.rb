class ApplicationWidgetTree < Apotomo::WidgetTree
  
  # This is an attempt to create a list/edit/filter widget with two such widgets within
  # Here, the book is the outermost widget, and it contains within it author and publisher widgets
  # Each of the three has a frame and three children: list, detail, and filter
  # draw_list_detail_filter_frame is supposed to create and wire up each of these in a consistent way,
  # which works with the methods in common_cell.rb.
  #
  # After that, some routes of communication need to be established between the outer and inner widgets.
  # The author and publisher frames are children of the book frame, even though they are in some
  # sense properly children of the book's edit panel, in order to avoid having them reset and redrawn
  # whenever the book's edit panel is redrawn.
  
  def draw(root)
      # create the three frame widgets first
      draw_book = draw_list_detail_filter_frame('book')
      draw_author = draw_list_detail_filter_frame('author')
      draw_publisher = draw_list_detail_filter_frame('publisher')
      # insert the book panel into root
      root << draw_book
      # insert the author and publisher panels as children of the book frame panel
      draw_book << draw_author
      draw_book << draw_publisher
      
      # Higher-level interactions:
      draw_book.watch(:showClick, 'author_detail', :_chosen)
      draw_book.watch(:showClick, 'publisher_detail', :_chosen)
      # A transition in the book's detail panel triggers updates to the author and publisher panels
      # book_list = find_child(draw_book, 'book_list')
      # book_detail = find_child(draw_book,'book_detail')
      # book_detail.watch(:showChildren, 'author_detail', :_show)
      # book_detail.watch(:showChildren, 'publisher_detail', :_show)
      # A selection from author or publisher panels triggers an update in the book detail panel
      # draw_author.watch(:chosenClick, 'book_detail', :_author_select, 'author_list')
      # draw_publisher.watch(:chosenClick, 'book_detail', :_publisher_select, 'publisher_list')
      author_list = find_child(draw_author,'author_list')
      publisher_list = find_child(draw_publisher,'publisher_list')
      author_list.watch(:chosenClick, 'author_list', :_chosen)
      publisher_list.watch(:chosenClick, 'publisher_list', :_chosen)
  end
  
  # This is a semi-generic frame/filter/list/detail widget
  # It should be fully functional for anything that doesn't need to communicate outside.
  # Perhaps later I'll work this into some kind of proper plugin for apotomo.
  def draw_list_detail_filter_frame(resource, opts = {})
    opts[:cell_sym] ||= resource.pluralize.to_sym
    opts[:prefix] ||= ''
    filter_name = opts[:prefix] + resource + '_filter'
    list_name = opts[:prefix] + resource + '_list'
    detail_name = opts[:prefix] + resource + '_detail'
    frame = cell(opts[:cell_sym], :_frame_start, opts[:prefix] + resource + '_frame', 
        :resource => resource, :panels => {:filter => filter_name, :list => list_name, :detail => detail_name})
      # Insert frame, list, and detail as children of the frame
      frame << filter = cell(opts[:cell_sym], :_filter_start, filter_name)
      frame << list = cell(opts[:cell_sym], :_list_start, list_name)
      frame << detail = cell(opts[:cell_sym], :_detail_start, detail_name)
      # Wire up the communication between panels.
      frame.watch(:editClick, detail.name, :_edit, nil)
      frame.watch(:showClick, detail.name, :_show, nil)
      frame.watch(:delClick, detail.name, :_delete, nil)
      frame.watch(:newClick, detail.name, :_new, nil)
      frame.watch(:dismissPanel, list.name, :_list_dismiss, filter.name)
      frame.watch(:dismissPanel, list.name, :_detail_dismiss, detail.name)
      frame.watch(:recordChanged, list.name, :_list, detail.name)
      frame.watch(:filterClick, filter_name, :filter_update, filter.name)
      frame.watch(:filterChanged, list.name, :_list, filter.name)
      frame.watch(:selectClick, list.name, :_list_select, detail.name)
      # edit, show, and delete clicks from the list trigger transitions in the detail panel
      # list.watch(:editClick, detail.name, :_edit)
      # list.watch(:showClick, detail.name, :_show)
      # list.watch(:delClick, detail.name, :_delete)
      # A "dismiss" button on the filter panel can hide the list if it is a HUD.
      # filter.watch(:dismissPanel, list.name, :_list_dismiss)
      # edit (from show) and new from the detail panel trigger transitions
      # detail.watch(:editClick, detail.name, :_detail)
      # detail.watch(:newClick, detail.name, :_new)
      # A "dismiss" button on the detail panel can hide it if it is a HUD.
      # detail.watch(:dismissPanel, detail.name, :_detail_dismiss)
      # select from the detail panel triggers transitions in the list and filter panels (unhides them)
      # detail.watch(:selectClick, list.name, :_list_select)
      # filter change in the filter panel triggers a transition in the filter, then an update of the list
      # filter.watch(:filterClick, filter.name, :_filter_update)
      # filter.watch(:filterChanged, list.name, :_list)
      # Clicking on the new link in the filter panel transitions the detail to the new record state
      # filter.watch(:newClick, detail.name, :_new)
      # when the record is updated, a recordChange sent by the detail panel triggers update in the list panel
      # detail.watch(:recordChanged, list.name, :_list)
    return frame
  end

  # This is a helper for finding child panels
  def find_child(root, widget_id)
    root.children.find_all do |w|
      return w if w.name.to_s == widget_id.to_s
    end
    nil
  end
  
end

