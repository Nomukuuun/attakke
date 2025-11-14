import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";

// Connects to data-controller="sortable"
export default class extends Controller {
  static values = { 
    locationId: Number,
    sortableStockId: Number
  };

  initialize() {
    this.dragging = false;                                             // ドラッグ状態フラグ（グローバルスクロール用）
    this.scrollDirection = null;                                       // スクロール方向フラグ　'up' or 'down'
    this._scrollDiscrimination = this.scrollDiscrimination.bind(this); // マウス位置によりスクロール方向を判別する関数のバインド
    this._scrollLoop = this.scrollLoop.bind(this);                     // スクロールループ関数のバインド
  }

  connect() {
    // スクロール方向アクションとループアクションの接続
    window.addEventListener("mousemove", this._scrollDiscrimination);
    window.addEventListener("touchmove", this._scrollDiscrimination, { passive: false });
    requestAnimationFrame(this._scrollLoop);

    this.sortable = Sortable.create(this.element, {
      group: "stocks_list",                       // 共通クラスを指定することで各保管場所のストック表示範囲内だけドロップ可能にする
      handle: ".drag-handle",                     // アイテムとして認識するclassを指定
      animation: 150,                             // 並び替えに移行するまでの長押し秒数指定(ms)
      onEnd: this.reorder.bind(this),             // 並び替え：ドロップ時に毎回発火
      onAdd: this.moveToOtherLocation.bind(this), // 配置換え：他のgroupにドロップした時のみ発火
      scroll: false,                              // Sortableのスクロール機能を無効
      onStart: () => {
        this.dragging = true;
      },                                          // スクロール：group内外問わずアイテム移動時に発火
    });
  }

  disconnect() {
    window.removeEventListener("mousemove", this._scrollDiscrimination);
    window.removeEventListener("touchmove", this._scrollDiscrimination);
  }

  // スクロール方向判定アクション
  scrollDiscrimination(e) {
    // ドラッグ中以外は処理しない
    if (!this.dragging) {
      this.scrollDirection = null;
      return;
    }

    const mouseY = e.clientY;                // 画面上のマウス位置取得
    const windowHeight = window.innerHeight; // アドレスバーなどを除くビューポートの高さ取得

    // 固定領域の高さ
    const header = document.getElementsByTagName("header");
    const submenu = document.getElementById("submenu");
    const locationHeader = document.querySelector(".location-header"); // 複数保管場所があったら最初の１件が返る
    const footerMenu = document.getElementsByTagName("nav");

    // オプショナルチェーン(?.)でnullの場合はundefinedを返す
    const fixedHeaderHeight =
      (header?.offsetHeight || 0) +
      (submenu?.offsetHeight || 0) +
      (locationHeader?.offsetHeight || 0);

    const fixedFooterHeight = (footerMenu?.offsetHeight || 0);

    // スクロール検知範囲(固定メニュー + ストック１つ分：84px ≒ 90px)
    const upperThreshold = fixedHeaderHeight + 90;
    const lowerThreshold = fixedFooterHeight + 90;

    // マウス位置がスクロール検知範囲内かどうかでスクロール方向を決定
    if (mouseY < upperThreshold) {
      this.scrollDirection = "up";
    } else if (mouseY > windowHeight - lowerThreshold) {
      this.scrollDirection = "down";
    } else {
      this.scrollDirection = null;
    }
  }

  // 実際にスクロールさせるアクション
  scrollLoop() {
    if (this.dragging && this.scrollDirection) {
      const scrollSpeed = 10;

      if (this.scrollDirection === "up") {
        window.scrollBy(0, -scrollSpeed);
      }
      if (this.scrollDirection === "down") {
        window.scrollBy(0, scrollSpeed);
      }
    }
    requestAnimationFrame(this._scrollLoop); // 再帰的にcallしてループ動作を継続する
  }

  reorder(event) {
    this.dragging = false; // ドロップ時に必ずグローバルスクロール用のフラグを解除する
    if (event.from === event.to) {
      // childrenで各stockのturbo-frame要素を取得でき、同タグにあるstock_id_valueを取得
      const ids = Array.from(this.element.children).map((el) => {
        return el.dataset.sortableStockIdValue;
      });

      // 入れ替え後のstocks_idsをjson形式でstocks/sortアクションに送信
      fetch("/stocks/sort", {
        method: "PATCH",
        headers: this.headers(),
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
      headers: this.headers(),
      body: JSON.stringify({
        location_ids: [oldLocationId, newLocationId],
        new_position: event.newIndex + 1, // newIndexは移動先リスト内での位置が0始まりで入っているので1を足してpositionに重複がないようにする
      }),
    });
  }

  headers() {
    return {
      "Accept": "text/vnd.turbo-stream.html, text/html, application/xhtml+xml", // turbo_streamでのリクエストとすることでフラッシュメッセージの更新を可能にする
      "Content-Type": "application/json",
      "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
    }
  }
}
