class BillController < ApplicationController

  def show
    @bill = Bill.find(params[:id])
  end

end
