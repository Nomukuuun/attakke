import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="quantity-visibility"
export default class extends Controller {
  static targets = [
    "existenceRadio",
    "numberRadio",
    "existenceField",
    "existenceQuantity",
    "checkedIcon",
    "notCheckedIcon",
    "numberField",
    "numberQuantity",
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

  // チェックボックス型のチェックあり/なしを切り替える
  toggleIcon() {
    const quantity = this.existenceQuantityTarget;

    if (quantity.value === "1") {
      this.checkedIconTarget.classList.add("hidden");
      this.notCheckedIconTarget.classList.remove("hidden");
      quantity.value = 0;
    } else {
      this.notCheckedIconTarget.classList.add("hidden");
      this.checkedIconTarget.classList.remove("hidden");
      quantity.value = 1;
    }
  }

  setInitialIconState() {
    const quantity = this.existenceQuantityTarget;

    if (quantity.value === "1") {
      this.checkedIconTarget.classList.remove("hidden");
      this.notCheckedIconTarget.classList.add("hidden");
    } else {
      this.checkedIconTarget.classList.add("hidden");
      this.notCheckedIconTarget.classList.remove("hidden");
    }
  }

  incrementNumber() {
    let value = this._safeValue();
    if (value < 100) {
      this.numberQuantityTarget.value = value + 1;
    }
  }

  decrementNumber() {
    let value = this._safeValue();
    if (value === 0) {
      this.numberQuantityTarget.value = 0;
    } else if (value > 0) {
      this.numberQuantityTarget.value = value - 1;
    }
  }

  // インクリ、デクリボタンを押したときに閾値内で値をセットする
  _safeValue() {
    let val = this.numberQuantityTarget.value;
    if (val === "" || val === null) return 0; // 入力が空なら 0 とみなす
    return parseInt(val, 10);
  }
}
