// Entry point for the build script in your package.json
import "@hotwired/turbo-rails";
import "./controllers";

// NOTE:relation, absoluteで対応できたため削除
// function adjustMainHeight() {
//   const main = document.querySelector("main");
//   const footer = document.querySelector("footer");
//   const header = document.querySelector("header");
//   const indexDiv = document.getElementById("index");

//   const vh = window.innerHeight;
//   const footerHeight = footer ? footer.offsetHeight : 0;
//   const headerHeight = header ? header.offsetHeight : 0;
//   const indexHeight = indexDiv ? indexDiv.offsetHeight : 0;
//   const windowHeight = vh - footerHeight; //フッターを除く画面高

//   //画面高とindexHeightのどちらが高いかによってmainのminHeightを設定する
//   if (indexHeight < windowHeight) {
//     main.style.minHeight = windowHeight + "px";
//   } else {
//     main.style.minHeight = indexHeight + headerHeight + "px";
//   }
// }

// window.addEventListener("DOMContentLoaded", adjustMainHeight);
// window.addEventListener("resize", adjustMainHeight);

// // 画面リサイズ時に高さを自動修正
// const indexDiv = document.getElementById("index");
// if (indexDiv && "ResizeObserver" in window) {
//   const resizeObserver = new ResizeObserver(adjustMainHeight);
//   resizeObserver.observe(indexDiv);
// }
// document.addEventListener("turbo:frame-render", adjustMainHeight);
// document.addEventListener("turbo:before-stream-render", adjustMainHeight);
