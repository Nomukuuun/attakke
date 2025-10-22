class PushNotificationJob < ApplicationJob
  queue_as :default

  def perform(subscription_id, message:, url: '/')
    subscription = Subscription.find(subscription_id)
    WebPush.payload_send(
      message: message.to_json,
      endpoint: subscription.endpoint,
      p256dh: subscription.p256dh,
      auth: subscription.auth,
      vapid: {
        public_key: ENV['VAPID_PUBLIC_KEY'],
        private_key: ENV['VAPID_PRIVATE_KEY']
        subject: ENV['VAPID_SUBJECT']
      }
    )
  rescue WebPush::InvalidSubscription
    subscription.destroy
  end
end
