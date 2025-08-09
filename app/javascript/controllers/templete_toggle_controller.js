import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="templete-toggle"
export default class extends Controller {
  static targets = ["content"];

  toggle(event) {
    const clickedId = event.currentTarget.dataset.id;
    const contentElement = document.getElementById(clickedId);

    // clickedされたel以外はhiddenを付与して閉じる
    this.contentTargets.forEach((el) => {
      if (el !== contentElement) {
        el.classList.add("hidden");
      }
    });

    // clickedされた要素のみトグルする
    if (contentElement) {
      contentElement.classList.toggle("hidden");
    }
  }
}
