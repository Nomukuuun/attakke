import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="quantity-visibility"
export default class extends Controller {
  static targets = [
    "quantityExistField",
    "quantityNumField",
    "existenceRadio",
    "numberRadio",
    "iconImage",
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

  toggleIconImage() {
    const image = this.iconImageTarget;
    const quantity = this.hiddenQuantityTarget;
    const explanation = this.iconExplanationTarget;

    const currentSrc = image.getAttribute("src");

    if (currentSrc.includes("icon_checked")) {
      // チェック外す => アイコンをunchecked、在庫数quantityを0に変更
      image.setAttribute("src", "/assets/icon_unchecked.png");
      explanation.textContent = "ストックなし";
      quantity.value = 0;
    } else {
      // チェック入れる => アイコンをchecked、在庫数quantityを1に変更
      image.setAttribute("src", "/assets/icon_checked.png");
      explanation.textContent = "ストックあり";
      quantity.value = 1;
    }
  }
}
