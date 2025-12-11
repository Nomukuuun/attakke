# 🛒 アプリ名：Attakke?（あったっけ？）

## ⬜ アプリ概要

「Attakke?」は、ご家庭の消耗品ストックを管理できるアプリです。  
保管場所ごとに消耗品ストックを管理することで、ストック状態の可視化と買い物リストを兼ねることを目的としています。

**アプリURL：https://mada-attakke.com/**  
アプリリリース記事：https://note.com/nomukuuun5/n/n5e5d8b6e27ea

## ⬜ デモアカウント

動作確認をする場合は以下のデモアカウントをご使用いただけます。

メールアドレス：**attakke.demo.app@gmail.com**  
パスワード：**attakke@123**

> [!Warning]  
> デモアカウントは共用です。  
> 個人情報などの登録はお控えください。  
> また、本アプリの動作確認以外の目的には使用しないでください。  

## ⬜ このアプリへの思い・作りたい理由

私は Todo リスト型の買い物メモアプリを使っています。  
買うものを記録して買い物に出かけ、必要なものだけを買うという点では重宝していますが、出先で「これまだストックあったっけ？」となることが多々ありました。

Todo リストタイプの買い物メモアプリでは、記録してきたものの購入状況しか確認できず、急いでつけてきたメモには漏れもよくありました。  
また、事前に買うものを確認する作業とリストに記録する作業があり、面倒だなと感じていました。

そこで**保管場所ごとの消耗品の状態を簡単に確認、更新できるアプリ**があれば、買いすぎや買い忘れによる失敗が減らせると考えました。

## ⬜ ユーザー層について

- 単身者（自身で消耗品を管理する必要がある方）
- ご夫妻（お互いに消耗品を管理する方）

## ⬜ アプリの利用イメージ

1. ご家庭の実態に合わせて、保管場所、消耗品ストックの順にリストを作成します。
2. 面倒な入力作業はテンプレート機能を活用して簡単に済ませます。
3. 買い物に出かけた先でリストと照合しながら必要な消耗品ストックを購入します。
4. ストック購入時、ストック消費時に簡単操作でリストを更新します。

## ⬜ 既存アプリの調査

#### 【使っている買い物メモアプリ】

**買い物リスト・メモ - Lisble リスブル**  
（参考 URL：https://play.google.com/store/apps/details?id=net.lisble.twa&hl=jp ）

こちらのアプリは UI が非常に分かりやすく、チュートリアルがなくても直感的に操作できたため使っています。  
便利なのですが、Todo リスト型の買い物メモアプリですので、ストック管理アプリとしての側面では向いていないと思いました。

#### 【類似しているアプリ】

**LisTa! -家族とシェアする買い物リスト-**  
（参考 URL：https://play.google.com/store/apps/details?id=dev.templat.lista&hl=ja ）

こちらのアプリは、複数の買い物リストを作ることができるため、  
冷蔵庫、キッチン...と保管場所ごとにリストを作ることでストック管理アプリとして機能します。  
ただ、機能が豊富なこともあり、操作に慣れるまで少し時間を要しました。  
また、ストックの登録が１つずつしか行えないこともあり、初期入力のハードルが高いと感じました。

## ⬜ 本アプリの推しポイント

<table>
  <tr>
    <th style="text-align:center;">保管場所に管理 / リスト切替</th>
    <th style="text-align:center;">ストックごとに選べる管理型</th>
  </tr>
  <tr>
    <td valign="top" style="text-align:center;">
      <img src="https://github.com/user-attachments/assets/0dcf05cf-22d1-4dda-bbe8-2afd4c1b3e38" width="350">
    </td>
    <td valign="top" style="text-align:center;">
      <img src="https://github.com/user-attachments/assets/0f227cfe-0645-4844-8333-bc088aecbf20" width="350">
    </td>
  </tr>
  <tr>
    <td valign="top">
      <div style="width:370px; text-align:left;">
        保管場所ごとにストック状況を一覧表示できます。<br>
        <strong>リスト切替機能</strong>を活用することで買いものリストとしての機能も提供します。
      </div>
    </td>
    <td valign="top">
      <div style="width:370px; text-align:left;">
        アイコンで有無を管理できる<strong>チェックボックス型</strong>、<br>
        残りが何個あるかで管理できる<strong>残数型</strong>、<br>
        ストックにあった管理型を選択して管理できます。
      </div>
    </td>
  </tr>
</table>

<br>

<table>
  <tr>
    <th style="text-align:center;">テンプレート機能</th>
    <th style="text-align:center;">ストック単位で履歴確認</th>
  </tr>
  <tr>
    <td valign="top" style="text-align:center;">
      <img src="https://github.com/user-attachments/assets/471a911f-2ec1-4286-8967-b9ac04467de8" width="350">
    </td>
    <td valign="top" style="text-align:center;">
      <img src="https://github.com/user-attachments/assets/231db4b0-c668-4f27-89b4-2c78c97177ce" width="350">
    </td>
  </tr>
  <tr>
    <td valign="top">
      <div style="width:370px; text-align:left;">
        最大10個までまとめてストックを作成できます。<br>
        <strong>プリセットとして登録済のテンプレートを使用できます。</strong><br>
        テンプレートは自由に内容を変更することもできるため、初期登録時におすすめの機能です。
      </div>
    </td>
    <td valign="top">
      <div style="width:370px; text-align:left;">
        一覧画面で最後に更新した日を確認できます。<br>
        <strong>ストックごとに履歴を確認</strong>できます。<br>
        前回購入した記録をつけ忘れてしまっても、履歴の購入頻度から買うべきかどうかの判断ができます。
      </div>
    </td>
  </tr>
</table>

<br>

<table>
  <tr>
    <th style="text-align:center;">直感的なソート機能</th>
    <th style="text-align:center;">LINE転送機能</th>
  </tr>
  <tr>
    <td valign="top" style="text-align:center;">
      <img src="https://github.com/user-attachments/assets/d885e610-e3c3-4dd0-8cf9-92aeb4dfa5fa" width="350">
    </td>
    <td valign="top" style="text-align:center;">
      <img src="https://github.com/user-attachments/assets/b57d601f-8445-4903-a1ea-e8d08b79e104" width="350">
    </td>
  </tr>
  <tr>
    <td valign="top">
      <div style="width:370px; text-align:left;">
        ソートモードをオンにするとアイコンが表示され、
        <strong>ドラッグアンドドロップで並べ替えや保管場所転換</strong>
        が行えます。<br>
        ソート中は操作できない部分が非表示や透過されるため、視覚的にも分かりやすくしています。
      </div>
    </td>
    <td valign="top">
      <div style="width:370px; text-align:left;">
        LINEへメッセージを転送できます。<br>
        送信メッセージはアプリ上で編集でき、送信する人はLINE上で選択できるため、
        <strong>本アプリを使っていない方にも買いもの依頼</strong>
        を送ることができます。
      </div>
    </td>
  </tr>
</table>

## ⬜ ユーザーの獲得について

- SNS での宣伝
- 近親者に使ってもらい機会があれば薦めてもらう

## ⬜ 機能の実装方針

### Google ログイン機能
メールアドレスの登録やパスワード設定など煩わしい工程を省きたかったため実装しました。  
また、数ある認証方法の中で Google 認証を選定した理由は以下２つになります。

1. 近親者へ聞き込みをした際に Google アカウントを所有していない者がいなかったこと。
2. NTT ドコモ モバイル社会研究所の調査によると Google アカウントの保有率は約 78%程度[^1]で最多であったこと。

### テンプレート機能
類似アプリでは、一度入力した情報を使いまわすためのテンプレート機能がありました。  
本アプリでは、初期入力のハードルを下げるために、プリセットとしてのテンプレートを用意しました。  
この機能の違いが類似アプリとの差別化ポイントになっています。

### SPA のような操作性  
常時、保管場所ごとに消耗品ストックを管理しておき、出かけた先で買うものに困らないようにすることが目的のアプリです。  

また、ストックの作成や更新、削除といった部分更新で済む操作が多いため、画面遷移で全体を描画しなおすのではなく、Turbo や Stimulus による非同期更新を積極的に採用しています。

### パートナー認証機能
ご夫妻で消耗品を管理できるようにするため、パートナー認証機能を実装しました。  
本アプリに登録済みのユーザー間で申請を送り、承諾されればお互いの保管場所、ストック状況を共有できるようになります。

### LINE転送機能
買いものリストの内容をテキストでLINEへ転送することができます。
ご夫妻で買いもの担当が決まっているなど、１人しかアプリを使っていない状況でも買ってきてほしいものを伝えることができる便利機能です。  

LIFFの Share Target Picker を利用することで、本アプリを利用していないユーザーに対してもLINE上で買いもの依頼を送れるように実装しました。  

### PWA 対応
出先でストック状況を確認することを想定しているため、操作はスマートフォンで行うことをメインに考えています。  
ブラウザからアプリにアクセスするのではなく、ネイティブアプリのようにホーム画面のアイコンからアクセスできるように PWA に関する設定を行いました。

## ⬜ 使用技術
| カテゴリ | 使用技術 |
| :--- | :--- |
| フロントエンド | TailwindCSS / Hotwire / LIFF |
| バックエンド | Ruby 3.3.6 / Rails 7.2.2.1 |
| データベース | PostgreSQL (Neon) |
| 開発環境 | Docker |
| インフラ | Render |
| 認証 | Devise / Omniauth (Google OAuth 2.0)  |

## ⬜ 画面遷移図
[Figmaで作成](https://www.figma.com/design/mvEe6hSXwwJiDg1PwbAS9v/Attakke-_%E7%94%BB%E9%9D%A2%E9%81%B7%E7%A7%BB%E5%9B%B3?node-id=4-30&t=SiPF4yKIkrv30xmM-1)

## ⬜ ER図
<img src="https://github.com/user-attachments/assets/359f2410-877a-4f6a-bf60-9e7bacb716a8" width="750"/>

[^1]: 10 代女性の 3 人に 1 人は Twitter、Instagram を３アカウント以上所有（2021 年 5 月 13 日）, https://www.moba-ken.jp/project/lifestyle/20210513.html, 1-1.「Google」「LINE」「Yahoo! Japan」「楽天」「Amazon」は過半数がアカウント所有, 2025-07-16 参照
