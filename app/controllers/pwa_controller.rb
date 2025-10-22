class PwaController < ApplicationController
  # CSRFトークンを無効化（Service Worker / manifestはJSやブラウザが直接GETするため）
  protect_from_forgery except: [:manifest, :service_worker]
  skip_before_action :authenticate_user!

  def manifest
    # キャッシュ対策で都度生成
    expires_in 0, public: true
    render "pwa/manifest", formats: [:json]
  end

  def service_worker
    expires_in 0, public: true
    render "pwa/service-worker", formats: [:js]
  end
end
