import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="push"
export default class extends Controller {
  static values = { publicKey: String }

  connect() {
    if (!("serviceWorker" in navigator) || !("PushManager" in window)) {
      console.log("Push notifications not supported in this browser.")
      return
    }

    this.registerPushSubscription()
  }

  async registerPushSubscription() {
    const permission = await Notification.requestPermission()
    if (permission !== "granted") {
      console.log("Push notification permission denied.")
      return
    }

    const registration = await navigator.serviceWorker.ready
    let subscription = await registration.pushManager.getSubscription()

    if (!subscription) {
      subscription = await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: this.urlBase64ToUint8Array(this.publicKeyValue)
      })
    }

    await this.sendSubscriptionToServer(subscription)
  }

  async sendSubscriptionToServer(subscription) {
    await fetch("/subscriptions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify(subscription)
    })
    console.log("Push subscription sent to server.")
  }

  urlBase64ToUint8Array(base64String) {
    const padding = "=".repeat((4 - (base64String.length % 4)) % 4)
    const base64 = (base64String + padding).replace(/\-/g, "+").replace(/_/g, "/")
    const rawData = atob(base64)
    return Uint8Array.from([...rawData].map((c) => c.charCodeAt(0)))
  }
}
