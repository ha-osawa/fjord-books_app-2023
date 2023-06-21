class Books::CommentsController < CommentsController
  before_action :set_commentable, only: %i[create destroy]

  private

  def set_commentable
    @commentable = Book.find(params[:book_id])
  end

  def render_show
    @book = @commentable
    render 'books/show', status: :unprocessable_entity
  end
end
