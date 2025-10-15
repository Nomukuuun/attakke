class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[privacy terms]

  def privacy ;end

  def terms ;end

  def tutorial ;end
end
