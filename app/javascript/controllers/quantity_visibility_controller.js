import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="quantity-visibility"
export default class extends Controller {
  static targets = [
    "existenceField",
    "numberField",
    "existenceRadio",
    "numberRadio",
    "existenceQuantity",
    "numberQuantity",
    "checkedIcon",
    "notCheckedIcon",
    "iconExplanation",
  ];

  connect() {
    this.changeModel(); // ラジオボタンによる表示制御
    this.setInitialIconState(); // exist_quantityの初期値に応じたアイコン表示
  }

  changeModel() {
    const existenceSelected = this.existenceRadioTarget.checked;

    if (existenceSelected) {
      this.existenceFieldTarget.classList.remove("hidden");
      this.numberFieldTarget.classList.add("hidden");
    } else {
      this.existenceFieldTarget.classList.add("hidden");
      this.numberFieldTarget.classList.remove("hidden");
    }
  }

  toggleIcon() {
    const quantity = this.existenceQuantityTarget;
    const explanation = this.iconExplanationTarget;

    if (quantity.value === "1") {
      this.checkedIconTarget.classList.add("hidden");
      this.notCheckedIconTarget.classList.remove("hidden");
      explanation.textContent = "ストックなし";
      quantity.value = 0;
    } else {
      this.notCheckedIconTarget.classList.add("hidden");
      this.checkedIconTarget.classList.remove("hidden");
      explanation.textContent = "ストックあり";
      quantity.value = 1;
    }
  }

  setInitialIconState() {
    const quantity = this.existenceQuantityTarget;
    const explanation = this.iconExplanationTarget;

    if (quantity.value === "1") {
      this.checkedIconTarget.classList.remove("hidden");
      this.notCheckedIconTarget.classList.add("hidden");
      explanation.textContent = "ストックあり";
    } else {
      this.checkedIconTarget.classList.add("hidden");
      this.notCheckedIconTarget.classList.remove("hidden");
      explanation.textContent = "ストックなし";
    }
  }
}
