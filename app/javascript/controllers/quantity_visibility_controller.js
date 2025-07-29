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
    this.changeModel();
  }

  changeModel(event) {
    const existenceSelected = this.existenceRadioTarget.checked;

    if (existenceSelected) {
      // チェックボックス型が選択されているときは残数型のフィールドを非表示かつ不活性化
      this.existenceFieldTarget.classList.remove("hidden");
      this.numberFieldTarget.classList.add("hidden");
      // this.existenceQuantityTarget.disabled = false;
      // this.numberQuantityTarget.disabled = true;
    } else {
      // 残数型が選択されているときはチェックボックス型のフィールドを非表示かつ不活性化
      this.existenceFieldTarget.classList.add("hidden");
      this.numberFieldTarget.classList.remove("hidden");
      // this.existenceQuantityTarget.disabled = true;
      // this.numberQuantityTarget.disabled = false;
    }
  }

  toggleIcon() {
    const quantity = this.existenceQuantityTarget;
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
