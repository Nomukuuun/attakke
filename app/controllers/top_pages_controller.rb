class TopPagesController < ApplicationController
  skip_before_action :authenticate_user!

  def top
    @description = [
      { number: "１",
        caption: "保管場所ごとに管理",
        img_url: "top_1.svg",
        sentence:
          "ストックを保管場所ごとに記録することで<br>
          管理や確認がしやすくなります<br>
          ご家庭の実態に合わせて<br>
          保管場所を設定しましょう"
      },

      { number: "２",
        caption: "選べる管理型",
        img_url: "top_2.svg",
        sentence:
          "ストックの有無を管理する<br>
          <strong>チェックボックス</strong><br>
          ストックの個数を管理する<br>
          <strong>残数表示</strong><br>
          ストックに合わせた型で管理できます"
      },

      { number: "３",
        caption: "テンプレートで楽々入力",
        img_url: "top_3.svg",
        sentence:
          "面倒な入力作業を楽にするための<br>
          テンプレート機能が使えます<br>
          保管場所名やストック名は<br>
          後から変更することも可能です"
      },

      { number: "４",
        caption: "ストックごとに履歴を確認可能",
        img_url: "top_4.svg",
        sentence:
          "ストックごとに履歴を確認することができます<br>
          ついつい記録を忘れてしまっても<br>
          出先で購入頻度を確認して<br>
          今買うべきか判断できます"
      }
    ]
  end
end
