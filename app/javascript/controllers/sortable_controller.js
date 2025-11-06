import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";

// Connects to data-controller="sortable"
export default class extends Controller {
  static values = { locationId: Number };

  connect() {
    // groupに共通クラスを指定することで各保管場所のストックフィールド内だけドロップ可能にする
    // onEndは保管場所を変えなくでもドロップ時に発火、onAddは保管場所を変えた時のみ発火する
    this.sortable = Sortable.create(this.element, {
      group: "stocks_list",
      handle: ".drag-handle",
      animation: 150,
      onEnd: this.reorder.bind(this),
      onAdd: this.moveToOtherLocation.bind(this),
    });
  }

  reorder(event) {
    if (event.from === event.to) {
      // childrenで各stockのturbo-frame要素を取得でき、同タグにあるstock_id_valueを取得
      const ids = Array.from(this.element.children).map((el) => {
        return el.dataset.sortableStockIdValue;
      });

      // 入れ替え後のstocks_idsをjson形式でstocks/sortアクションに送信
      fetch("/stocks/sort", {
        method: "PATCH",
        headers: this.headers,
        body: JSON.stringify({
          stock_ids: ids,
          location_id: this.locationIdValue,
        }),
      });
    }
  }

  // eventにはSortableJsによりドラッグ操作の詳細情報が入っている
  moveToOtherLocation(event) {
    const stockId = event.item.dataset.sortableStockIdValue; // 実際に動かした要素
    const oldLocationId = Number(event.from.dataset.sortableLocationIdValue); // ドロップ前location_id
    const newLocationId = this.locationIdValue; // ドロップ先location_id

    fetch(`/stocks/${stockId}/rearrange`, {
      method: "PATCH",
      headers: this.headers,
      body: JSON.stringify({
        location_ids: [oldLocationId, newLocationId],
        new_position: event.newIndex + 1, // newIndexは移動先リスト内での位置が0始まりで入っているので1を足してpositionに重複がないようにする
      }),
    });
  }

  get headers() {
    return {
      "Content-Type": "application/json",
      "Accept": "text/vnd.turbo-stream.html", // turbo_streamでのリクエストとすることでフラッシュメッセージの更新を可能にする
      "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
        .content,
    }
  }
}
