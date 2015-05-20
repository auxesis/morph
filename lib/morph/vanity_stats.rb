module Morph
  class VanityStats
    # Include rows that have been changed and created
    def self.total_database_rows_updated_in_last_week
      Run.where("finished_at > ?", 7.days.ago).sum(:records_added) + Run.where("finished_at > ?", 7.days.ago).sum(:records_changed)
    end

    def self.total_pages_scraped_in_last_week
      ConnectionLog.where("created_at > ?", 7.days.ago).count
    end

    def self.total_api_queries_in_last_week
      ApiQuery.where("created_at > ?", 7.days.ago).count
    end
  end
end
