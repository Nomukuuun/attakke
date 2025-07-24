import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="quantity-visibility"
export default class extends Controller {
  static targets = [
    "quantityExistField",
    "quantityNumField",
    "existenceRadio",
    "numberRadio",
  ];

  connect() {
    this.toggleQuantityField();
  }

  toggleQuantityField() {
    if (this.numberRadioTarget.checked) {
      this.quantityNumFieldTarget.classList.remove("hidden");
      this.quantityExistFieldTarget.classList.add("hidden");
    } else {
      this.quantityExistFieldTarget.classList.remove("hidden");
      this.quantityNumFieldTarget.classList.add("hidden");
    }
  }

  changeModel() {
    this.toggleQuantityField();
  }
}
