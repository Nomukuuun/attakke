import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="filter-buttons"
export default class extends Controller {
  static targets = ["button"];

  activate(event) {
    this.buttonTargets.forEach((button) => {
      button.classList.remove(
        "text-white",
        "border-dull-green",
        "bg-dull-green",
        "hover:brightness-70"
      );
      button.classList.add(
        "text-f-head",
        "border-black",
        "bg-white",
        "hover:text-white",
        "hover:bg-dull-green",
        "hover:border-dull-green"
      );
    });

    const currentButtonTarget = event.currentTarget.querySelector("div");
    currentButtonTarget.classList.add(
      "text-white",
      "border-dull-green",
      "bg-dull-green",
      "hover:brightness-70"
    );
    currentButtonTarget.classList.remove(
      "text-f-head",
      "border-black",
      "bg-white",
      "hover:text-white",
      "hover:bg-dull-green",
      "hover:border-dull-green"
    );
  }
}
