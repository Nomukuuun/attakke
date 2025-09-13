import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="templete-select"
export default class extends Controller {
  static targets = ["container", "row", "templete", "notice"];

  connect() {}

  // フォームを動的に表示するアクション
  change(event) {
    const locationName = event.target.value;
    const frame = document.getElementById("templete_form_frame");

    if (locationName) {
      frame.src = `/templetes/form?location_name=${encodeURIComponent(
        locationName
      )}`;
    } else {
      frame.innerHTML = ""; // 未選択ならフォームを消す
    }
  }

  // フォームを動的に追加・削除するアクション
  add(event) {
    event.preventDefault();
    // テンプレート HTML を取得
    const templete = this.templeteTarget.innerHTML;

    // 既存フォームの最大 index を取得
    const existingIndexes = Array.from(
      this.containerTarget.querySelectorAll(
        "[data-templete-select-target='row']"
      )
    ).map((row) => parseInt(row.id, 10));
    console.log("existingIndexes", existingIndexes);

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

  remove(event) {
    event.preventDefault();
    const row = event.target.closest("[data-templete-select-target='row']");
    this.noticeTarget.classList.add("hidden");
    if (row) row.remove();
  }
}
