import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";

// Connects to data-controller="sortable"
export default class extends Controller {
  static values = { locationId: Number };

  connect() {
    // data-controllerをstocksの親要素に指定
    // groupに特定のlocation_idを持つ要素を指定することでその location 内だけドラッグ可能にする
    this.sortable = Sortable.create(this.element, {
      group: `location-${this.locationIdValue}`,
      handle: ".drag-handle",
      animation: 150,
      onEnd: this.update.bind(this),
    });
  }

  update() {
    // childrenで各stockのturbo-frame要素を取得でき、同タグにあるstock_id_valueを取得
    const ids = Array.from(this.element.children).map((el) => {
      return el.dataset.sortableStockIdValue;
    });

    // 入れ替え後のstocks_idsをjson形式でstocks/sortアクションに送信
    fetch("/stocks/sort", {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
          .content,
      },
      body: JSON.stringify({ stock_ids: ids }),
    });
  }
}
