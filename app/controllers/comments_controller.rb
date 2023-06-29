# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :ensure_user, only: %i[destroy]
  before_action :set_commentable, only: %i[create destroy]

  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.user_id = current_user.id
    if @comment.save
      redirect_to @commentable, notice: t('controllers.common.notice_create', name: Comment.model_name.human)
    else
      @comments = @commentable.comments
      render_show
    end
  end

  def destroy
    return redirect_to @commentable, alert: t('controllers.common.edit_destroy_restriction', name: Comment.model_name.human) unless @target_comment

    @commentable.comments.find(params[:id]).destroy
    redirect_to @commentable, notice: t('controllers.common.notice_destroy', name: Comment.model_name.human)
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end

  def ensure_user
    current_user_comments = current_user.comments
    @target_comment = current_user_comments.find_by(id: params[:id])
  end
end
