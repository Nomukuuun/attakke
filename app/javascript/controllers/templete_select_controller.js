import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="templete-select"
export default class extends Controller {
  connect() {}

  // フォームを動的に表示するアクション
  change(event) {
    const locationName = event.target.value;
    const frame = document.getElementById("templete_form_frame");

    if (locationName) {
      // 選択されたチェックボックスの部分テンプレートを描画
      frame.src = `/templetes/form?how_to_create=${encodeURIComponent(
        locationName
      )}`;
    } else {
      // 未選択ならフォームを消す
      frame.innerHTML = "";
      return;
    }
  }
}
