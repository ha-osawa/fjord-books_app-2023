# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    @users = User.order(:id).with_attached_icon.page(params[:page])
  end

  def show
    @user = User.find(params[:id])
  end
end
