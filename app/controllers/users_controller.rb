# deviseとは関係ないユーザー情報詳細を表示するためのコントローラ
class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
  end
end
