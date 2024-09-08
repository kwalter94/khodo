require "../../../spec/support/factories/**"

# Add seeds here that are *required* for your app to work.
# For example, you might need at least one admin user or you might need at least
# one category for your blog posts for the app to work.
#
# Use `Db::Seed::SampleData` if your only want to add sample data helpful for
# development.
class Db::Seed::RequiredData < LuckyTask::Task
  summary "Add database records required for the app to work"

  def call
    ["Income", "Expense", "Asset", "Liability"].each do |name|
      puts "Creating account type: #{name}"
      next if AccountTypeQuery.new.name(name).first?

      SaveAccountType.create!(name: name)
    end

    puts "Done adding required data"
  end
end
