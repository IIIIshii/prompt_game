class Admin::DaysController < ApplicationController
  before_action :authenticate_admin

  def index
    @days = Day.order(created_at: :asc)
  end

  def toggle_status
    @day = Day.find(params[:id])
    if @day.active?
      @day.update(status: :inactive)
      notice_message = "Day #{@day.id} を無効化しました"
    else
      @day.update(status: :active)
      notice_message = "Day #{@day.id} を有効化しました"
    end
    redirect_to admin_days_path, notice: notice_message
  end

  private

  def authenticate_admin
    unless session[:admin_authenticated]
      if params[:admin_pass] == ENV["ADMIN_PASS"]
        session[:admin_authenticated] = true
      else
        render plain: "管理者パスワードを入力してください: /admin/days?admin_pass=YOUR_PASSWORD", status: :unauthorized
        return
      end
    end
  end
end

