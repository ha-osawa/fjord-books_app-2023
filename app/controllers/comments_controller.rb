class CommentsController < ApplicationController

  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.user_id = current_user.id
    if @comment.save
      redirect_to @commentable, notice: 'コメントが作成されました'
    else
      redirect_to @commentable, notice: 'コメント作成されとらんよ'
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
