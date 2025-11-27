class LineMessagesController < ApplicationController
  include SetLocationsAndStocks

  before_action :set_locations_and_stocks, only: %i[edit share]

  def edit
    set_shopping_and_notinshopping_stocks(@stocks)
    @form = LineMessagesForm.new(message: default_message(@shopping_stocks))
  end

  def share
    @form = LineMessagesForm.new(line_message_params)

    if @form.invalid?
      set_shopping_and_notinshopping_stocks(@stocks)
      render :edit, status: :unprocessable_entity
    else
      # ここで share.html.erb を表示して、
      # その中の JS が liff.shareTargetPicker(@form.message) を呼ぶ形にする
      render :share
    end
  end

  # NOTE: 以下privateメソッド
  private

  def line_message_params
    params.require(:line_messages_form).permit(:message)
  end

  def set_shopping_and_notinshopping_stocks(stocks)
    @shopping_stocks = stocks.shopping
    @not_in_shopping_stocks = stocks.not_in_shopping
  end

  def default_message(shopping_stocks)
    message = <<~MSG
      【消耗品管理アプリ | Attakke】より
      パートナーから買いものお願い依頼が来ました！
      これを買ってきてほしいみたいです👇
      #{if shopping_stocks.present?
          shopping_stocks.map {|stock| "・#{stock.name}" }.join("\n")
        else
          "＊買いものリストにストックがありません。\n＊「買いものリストにないもの」を参考に買ってきてほしいストックを入力してください。"
        end
      }
      買いものリストはアプリからも確認ができます！
      #{root_url}
    MSG
    return message
  end
end
