import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="quantity-visibility"
export default class extends Controller {
  static targets = [
    "quantityExistField",
    "quantityNumField",
    "existenceRadio",
    "numberRadio",
    "checkedIcon",
    "notCheckedIcon",
    "iconExplanation",
    "hiddenQuantity",
  ];

  connect() {
    this.changeModel();
  }

  changeModel(event) {
    const existenceSelected = this.existenceRadioTarget.checked;

    if (existenceSelected) {
      // チェックボックス型が選択されているときは残数型のフィールドを非表示かつ不活性化
      this.quantityExistFieldTarget.classList.remove("hidden");
      this.quantityNumFieldTarget.classList.add("hidden");
      this.hiddenQuantityTarget.disabled = false;
      const numField = this.quantityNumFieldTarget.querySelector("input");
      if (numField) numField.disabled = true;
    } else {
      // 残数型が選択されているときはチェックボックス型のフィールドを非表示かつ不活性化
      this.quantityExistFieldTarget.classList.add("hidden");
      this.quantityNumFieldTarget.classList.remove("hidden");
      this.hiddenQuantityTarget.disabled = true;
      const numField = this.quantityNumFieldTarget.querySelector("input");
      if (numField) numField.disabled = false;
    }
  }

  toggleIcon() {
    // const checked = this.checkedIconTarget;
    // const not_checked = this.notCheckedIconTarget;
    const quantity = this.hiddenQuantityTarget;
    const explanation = this.iconExplanationTarget;

    if (quantity.value === "1") {
      // チェック外す => アイコンをunchecked、在庫数quantityを0に変更
      this.checkedIconTarget.classList.add("hidden");
      this.notCheckedIconTarget.classList.remove("hidden");
      explanation.textContent = "ストックなし";
      quantity.value = 0;
    } else {
      // チェック入れる => アイコンをchecked、在庫数quantityを1に変更
      this.notCheckedIconTarget.classList.add("hidden");
      this.checkedIconTarget.classList.remove("hidden");
      explanation.textContent = "ストックあり";
      quantity.value = 1;
    }
  }
}
