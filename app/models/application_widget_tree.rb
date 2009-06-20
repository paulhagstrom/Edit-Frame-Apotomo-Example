class ApplicationWidgetTree < Apotomo::WidgetTree
  include EditFrame::EditFrameWidgetTree
  
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
      book_frame = draw_list_detail_filter_frame('book')
      author_frame = draw_list_detail_filter_frame('author')
      publisher_frame = draw_list_detail_filter_frame('publisher')
      
      # This is supposed to be done with embed_frame, but it wasn't working
      # root << embed_frame(embed_frame(book_frame, author_frame), publisher_frame)
      root << book_frame
      book_frame << author_frame
      book_frame << publisher_frame
      book_frame['book_detail'] << cell(:authors, :_selected_start, 'author_selected', :resource => 'author')
      book_frame['book_detail'] << cell(:publishers, :_selected_start, 'publisher_selected', :resource => 'publisher')
      book_frame.watch(:recordChanged, 'author_selected', :_selected_start, 'author_detail')
      book_frame.watch(:recordChanged, 'publisher_selected', :_selected_start, 'publisher_detail')
      book_frame.watch(:recordChanged, 'book_list', :_list, 'publisher_detail')
      book_frame.watch(:recordChanged, 'book_list', :_list, 'author_detail')
      book_frame.watch(:selectClick, 'author_selected', :_selected_change, 'author_list')
      book_frame.watch(:selectClick, 'publisher_selected', :_selected_change, 'publisher_list')
      book_frame.watch(:parentShow, 'author_detail', :_show_from_parent, nil)
      book_frame.watch(:parentShow, 'publisher_detail', :_show_from_parent, nil)
      # root
  end
    
end

