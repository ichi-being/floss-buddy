class FlossRecordsController < ApplicationController
  before_action :login_required

  def index
    @floss_records = current_user.floss_records.order(record_date: :desc)
  end

  def create
    @floss_record = current_user.floss_records.new(floss_record_params)
    last_record = current_user.floss_records.order(date: :desc).first

    if last_record && last_record.date == Date.yesterday
      @floss_record.consecutive_count = last_record.consecutive_count + 1
    else
      @floss_record.consecutive_count = 1
    end

    if @floss_record.save
      # 成功した場合の処理
      redirect_to profile_path, notice: 'フロス実施記録を作成しました。'
    else
      # エラーがある場合の処理
      flash.now[:alert] = 'エラーが発生しました。'
      render :new
    end
  end

  private

  def floss_record_params
    params.require(:floss_record).permit(:record_date)
  end
end
