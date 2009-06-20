class BooksController < ApplicationController
  include Apotomo::ControllerMethods
  include Apotomo::WidgetShortcuts
  
  layout "default"
  
  def index
    ApplicationWidgetTree.new.draw([])
    @content = render_widget('book')
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

end
