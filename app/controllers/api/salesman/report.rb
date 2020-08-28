module API
  module SALESMAN
    class Report < Grape::API
      resource :report do

        route_param :id do
          resource :sale_report do
            desc "POST report/:id/sale_report"
            params do
              optional :date_type, type: Integer
            end
            post do
              start_time = Time.now
              start_time.strftime("%Y-%m-%d %H:%M:%S")

              if params[:date_type] == 3 # month
                previous_start_time = start_time.beginning_of_month
                previous_end_time = start_time.end_of_month

                #previous_end_time = previous_start_time.end_of_month.beginning_of_month
              elsif params[:date_type] == 2 # week
                previous_start_time = start_time.beginning_of_week
                previous_end_time = start_time.end_of_week

              elsif params[:date_type] == 1 # day
                previous_start_time = start_time.beginning_of_day
                previous_end_time = start_time.end_of_day

              end
              Rails.logger.info("previous_start_time ===  + #{previous_start_time}  dayend =  #{previous_end_time} ")
              sale_reports = ProductSaleItem.report_sale_delivered(params[:id], previous_start_time, previous_end_time)
              present :sale_report, sale_reports.first, with: API::SALESMAN::Entities::SaleReport

            end
          end
        end
      end
    end
  end
end

