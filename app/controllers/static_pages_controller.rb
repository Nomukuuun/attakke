class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[privacy terms]
  skip_before_action :current_list_type
  skip_before_action :current_sort_mode

  def privacy
    yaml_path = Rails.root.join("config", "privacy.yml")
    @privacy = YAML.load_file(yaml_path)["privacy"]
  end

  def terms
    yaml_path = Rails.root.join("config", "terms.yml")
    @terms = YAML.load_file(yaml_path)["terms"]
  end

  # チュートリアルのみERB構文（画像読み込み）を含むため、部分テンプレートを読み込んで展開する
  def tutorial
    yaml_path = Rails.root.join("config", "tutorials.yml")
    @tutorials = YAML.load_file(yaml_path)["tutorials"]
  end
end
