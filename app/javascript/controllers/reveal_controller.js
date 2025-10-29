import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    threshold: { type: Number, default: 0.2 }
  }

  connect() {
    if (!("IntersectionObserver" in window)) {
      this.reveal()
      return
    }

    this.observer = new IntersectionObserver((entries, observer) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          this.reveal()
          observer.unobserve(entry.target)
        }
      })
    }, { threshold: this.thresholdValue })

    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  reveal() {
    this.element.classList.add("opacity-100", "translate-y-0")
    this.element.classList.remove("opacity-0", "translate-y-10")
  }
}
