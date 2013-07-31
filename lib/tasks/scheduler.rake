namespace :monitor do
  desc "updating feeds"
  task :feed, [:url, :collection_id] => [:environment] do |t, args|
    puts "Scheduling new feed check: "+args.url
    FeedUpdateWorker.perform_async(args.url, args.collection_id)
    #FeedPopUp.update_from_feed(args.url, args.collection_id)
    puts "done."
  end
end