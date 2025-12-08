# deviseとは関係ないユーザー情報詳細を表示するためのコントローラ

class UsersController < ApplicationController
  before_action :authenticate_user!

  def show; end
end
