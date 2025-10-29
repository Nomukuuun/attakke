import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["open", "close", "mobileMenus", "panel"];

  connect() {
    this.finishClosing = this.finishClosing.bind(this);
    this.handleEscape = this.handleEscape.bind(this);
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleEscape);
  }

  toggle(event) {
    event.preventDefault();

    if (this.isOpen) {
      this.closeMenu();
    } else {
      this.openMenu();
    }
  }

  close(event) {
    event?.preventDefault();
    this.closeMenu();
  }

  reset() {
    this.closeMenu({ instant: true });
  }

  openMenu() {
    this.panelTarget.removeEventListener("transitionend", this.finishClosing);

    this.openTarget.classList.add("hidden");
    this.closeTarget.classList.remove("hidden");

    this.mobileMenusTarget.classList.add("drawer-container--open");
    this.mobileMenusTarget.setAttribute("aria-hidden", "false");

    requestAnimationFrame(() => {
      this.mobileMenusTarget.classList.add("drawer-container--visible");
    });

    document.addEventListener("keydown", this.handleEscape);
  }

  closeMenu({ instant = false } = {}) {
    this.openTarget.classList.remove("hidden");
    this.closeTarget.classList.add("hidden");

    if (instant) {
      this.mobileMenusTarget.classList.remove(
        "drawer-container--visible",
        "drawer-container--open"
      );
      this.mobileMenusTarget.setAttribute("aria-hidden", "true");
      document.removeEventListener("keydown", this.handleEscape);
      return;
    }

    if (
      !this.isOpen &&
      !this.mobileMenusTarget.classList.contains("drawer-container--visible")
    ) {
      return;
    }

    this.mobileMenusTarget.classList.remove("drawer-container--visible");
    this.mobileMenusTarget.setAttribute("aria-hidden", "true");

    this.panelTarget.removeEventListener("transitionend", this.finishClosing);
    this.panelTarget.addEventListener("transitionend", this.finishClosing, {
      once: true,
    });

    document.removeEventListener("keydown", this.handleEscape);
  }

  finishClosing() {
    if (this.mobileMenusTarget.classList.contains("drawer-container--visible"))
      return;
    this.mobileMenusTarget.classList.remove("drawer-container--open");
  }

  handleEscape(event) {
    if (event.key === "Escape") {
      this.closeMenu();
    }
  }

  get isOpen() {
    return this.mobileMenusTarget.classList.contains("drawer-container--open");
  }
}
