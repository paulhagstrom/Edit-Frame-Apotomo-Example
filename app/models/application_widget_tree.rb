class ApplicationWidgetTree < Apotomo::WidgetTree
  include EditFrameWidgetsTree
  
  # This is an attempt to create a list/edit/filter widget with two such widgets within
  # Here, the book is the outermost widget, and it contains within it author and publisher widgets
  # Each of the three has a frame and three children: list, detail, and filter
  # draw_list_detail_filter_frame is supposed to create and wire up each of these in a consistent way,
  # which works with the methods in common_cell.rb.
  #
  # After that, some routes of communication need to be established between the outer and inner widgets.
  # The author and publisher frames are children of the book frame, even though they are in some
  # sense properly children of the book's edit panel, in order to avoid having them reset and redrawn
  # whenever the book's edit panel is redrawn.  All of the important stuff here is taken care of in embed_frame.
  
  def draw(root)
      # create the three frame widgets first
      book_frame = draw_list_detail_filter_frame('book')
      author_frame = draw_list_detail_filter_frame('author')
      publisher_frame = draw_list_detail_filter_frame('publisher')
      
      root << embed_frame(embed_frame(book_frame, author_frame), publisher_frame)
  end
    
end

