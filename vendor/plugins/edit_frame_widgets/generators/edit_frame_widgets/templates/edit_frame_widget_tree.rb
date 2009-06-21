class ApplicationWidgetTree < Apotomo::WidgetTree
  include EditFrameWidgetsTree
  include EditFrameWidgets
    
  def draw(root)
      # create a parent frame (use a real model name instead of 'book')
      # with examples in comments for how to create children
      book_frame = draw_list_detail_filter_frame('book')
      # author_frame = draw_list_detail_filter_frame('author')
      # publisher_frame = draw_list_detail_filter_frame('publisher')

      root << book_frame
      # root << embed_frame(embed_frame(book_frame, author_frame), publisher_frame)
  end
    
end

