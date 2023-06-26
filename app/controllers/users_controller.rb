# frozen_string_literal: true

class UsersController < ApplicationController
  PAGENATION_NUMBER = 3

  def index
    @users = User.order(:id).page(params[:page]).per(PAGENATION_NUMBER)
  end

  def show
    @user = User.find(params[:id])
  end
end
