class BooksController < ApplicationController
  include Apotomo::ControllerMethods
  include Apotomo::WidgetShortcuts
  
  layout "default"
  
  def index
    ApplicationWidgetTree.new.draw([])
    @content = render_widget('book_frame')
    # @content = render_widget('author_frame')
    # @content = render_widget('publisher_frame')
  end
  
  def populate
    Book.delete_all
    Author.delete_all
    Publisher.delete_all
    (nc = Author.new(:name => 'Noam Chomsky')).save
    (cb = Author.new(:name => 'Cedric Boeckx')).save
    (nr = Author.new(:name => 'Norvin Richards')).save
    (mitp = Publisher.new(:name => 'MIT Press')).save
    (oup = Publisher.new(:name => 'Oxford University Press')).save
    (jb = Publisher.new(:name => 'John Benjamins')).save
    nc.reload
    cb.reload
    nr.reload
    mitp.reload
    oup.reload
    Book.new(:title => 'Aspects of the Theory of Syntax', :author => nc, :publisher => mitp).save
    Book.new(:title => 'Bare Syntax', :author => cb, :publisher => oup).save
    Book.new(:title => 'Islands and Chains', :author => cb, :publisher => jb).save
    Book.new(:title => 'Movement in Language', :author => nr, :publisher => oup).save
    redirect_to :action => 'index'
  end

  # Patch. This requirement of not being a String is no good.
  # def render_page_update_for(processed_handlers)
  #   render :update do |page|
  #     
  #     processed_handlers.each do |item|
  #     (handler, content) = item
  #       ### DISCUSS: i don't like that switch, but moving this behaviour into the
  #       ###   actual handler is too complicated, as we just need replace and exec.
  #       #content = handler.content
  #       next unless content ### DISCUSS: move this decision into EventHandler#process_event_for(page).
  # 
  #       if handler.kind_of? Apotomo::InvokeEventHandler
  #         page.replace handler.widget_id, content
  #       else
  #         page << content
  #       end
  #     end
  #     
  #   end 
  # end

end
