import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="templete-select"
export default class extends Controller {
  static targets = [
    "container", //フォームをラップする枠
    "fieldRow", //フィールド単位
    "model", //選択されている型のenum値
    "existField", //チェックボックス型の単位
    "checkedIcon", //チェックありアイコン
    "notCheckedIcon", //チェックなしアイコン
    "existQuantity", //チェックボックス型のフィールド値
    "numField", //残数表示型の単位
    "numQuantity", //残数表示型のフィールド値
    "templete", //フォームのテンプレートタグ
    "notice", //追加ボタンで警告表示を表示する用
  ];

  connect() {}

  // チェックボックス型アイコンのトグル
  toggleIcon(event) {
    const fieldRow = event.target.closest(
      "[data-templete-select-target='fieldRow']"
    );
    const checkedIcon = fieldRow.querySelector(
      "[data-templete-select-target='checkedIcon']"
    );
    const notCheckedIcon = fieldRow.querySelector(
      "[data-templete-select-target='notCheckedIcon']"
    );
    const existQuantity = fieldRow.querySelector(
      "[data-templete-select-target='existQuantity']"
    );

    if (existQuantity.value == 1) {
      checkedIcon.classList.add("hidden");
      notCheckedIcon.classList.remove("hidden");
      existQuantity.value = 0;
    } else {
      checkedIcon.classList.remove("hidden");
      notCheckedIcon.classList.add("hidden");
      existQuantity.value = 1;
    }
  }

  // 表示しているフィールドを変更する
  changeField(event) {
    const fieldRow = event.target.closest(
      "[data-templete-select-target='fieldRow']"
    );
    const existField = fieldRow.querySelector(
      "[data-templete-select-target='existField']"
    );
    const numField = fieldRow.querySelector(
      "[data-templete-select-target='numField']"
    );

    if (existField.classList.contains("hidden")) {
      numField.classList.add("hidden");
      existField.classList.remove("hidden");
    } else {
      numField.classList.remove("hidden");
      existField.classList.add("hidden");
    }
  }

  // フォームを動的に表示するアクション
  change(event) {
    const locationName = event.target.value;
    const frame = document.getElementById("templete_form_frame");

    if (locationName) {
      // 選択されたチェックボックスの部分テンプレートを描画
      frame.src = `/templetes/form?location_name=${encodeURIComponent(
        locationName
      )}`;
    } else {
      // 未選択ならフォームを消す
      frame.innerHTML = "";
      return;
    }
  }

  // フォームを追加アクション
  add(event) {
    event.preventDefault();
    // テンプレート HTML を取得
    const templete = this.templeteTarget.innerHTML;
    console.log(templete);

    // 既存フォームの最大 index を取得
    const existingIndexes = Array.from(
      this.containerTarget.querySelectorAll(
        "[data-templete-select-target='fieldRow']"
      )
    ).map((fieldRow) => parseInt(fieldRow.id, 10));

    // フォーム数が10以下かどうかでアクションを分岐
    if (existingIndexes.length < 10) {
      const maxIndex = existingIndexes.length
        ? Math.max(...existingIndexes)
        : -1;
      const newIndex = maxIndex + 1;

      // __INDEX__ を置換してユニークな name 属性にする
      const content = templete.replace(/__INDEX__/g, newIndex);

      // フォームを追加
      this.containerTarget.insertAdjacentHTML("beforeend", content);
      this.noticeTarget.classList.add("hidden");
    } else {
      this.noticeTarget.classList.remove("hidden");
    }
  }

  // フォームを削除アクション
  remove(event) {
    event.preventDefault();
    const fieldRow = event.target.closest(
      "[data-templete-select-target='fieldRow']"
    );
    this.noticeTarget.classList.add("hidden");
    if (fieldRow) fieldRow.remove();
  }

  // 残数フィールドの値を +1（100 を上限）
  incrementNumber(event) {
    const fieldRow = event.target.closest(
      "[data-templete-select-target='fieldRow']"
    );
    const numQuantity = fieldRow.querySelector(
      "[data-templete-select-target='numQuantity']"
    );
    numQuantity.value = Math.min(
      parseInt(numQuantity.value || 0, 10) + 1,
      100
    ).toString();
  }

  // 残数フィールドの値を -1（0 を加減）
  decrementNumber(event) {
    const fieldRow = event.target.closest(
      "[data-templete-select-target='fieldRow']"
    );
    const numQuantity = fieldRow.querySelector(
      "[data-templete-select-target='numQuantity']"
    );
    numQuantity.value = Math.max(
      parseInt(numQuantity.value || 0, 10) - 1,
      0
    ).toString();
  }
}
