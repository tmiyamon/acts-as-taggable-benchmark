namespace :bench do

  def create_fixtures count
    (0...count).map{|n| { name: "name_#{n}", skill: "skill_#{n}" }}
  end

  def sample_ids_of model, count
    ids = model.pluck(:id)
    (0...count).map{ ids.sample }
  end

  def puts_bench_name task_name
    puts "\n###################################################################\n\n"
    puts "#{task_name}"
  end

  desc "clean"
  task :clean => :environment do
    [
      ActsAsTaggableOn::Tag,
      ActsAsTaggableOn::Tagging,
      TaggableUser,
      TaggableArrayUser
    ].each do |model|
      if model.delete_all > 0
        puts "Deleted all #{model.name}"
      end
    end
    puts 'Finsihed to clean'
    puts ''
  end

  task write: :clean do |task_name|
    trial_count = 1000
    data = create_fixtures trial_count

    puts_bench_name task_name

    Benchmark.bmbm do |x|
      x.report("Using Taggable") do
        data.each do |d|
          TaggableUser.create name: d[:name], skill_list: [d[:skill]]
        end
      end
      x.report("Using Postgres Arrays") do
        data.each do |d|
          TaggableArrayUser.create name: d[:name], skills: [d[:skill]]
        end
      end
    end
  end

  task find_by_id: :environment do |task_name|
    if TaggableUser.count == 0 or TaggableArrayUser.count == 0
      puts "First you need to run writes task: 'rake bench:writes'"
    else
      puts_bench_name task_name

      trial_count = 1000
      taggable_user_ids = sample_ids_of TaggableUser, trial_count
      taggable_array_user_ids = sample_ids_of TaggableArrayUser, trial_count

      Benchmark.bmbm do |x|
        x.report("Using Taggable") do
          taggable_user_ids.each do |id|
            TaggableUser.includes(taggings: :tag).find_by_id(id);
          end
        end
        x.report("Using Postgres Arrays") do
          taggable_array_user_ids.each do |id|
            TaggableArrayUser.find_by_id(id)
          end
        end
      end
    end
  end

  task find_by_tag: :environment do |task_name|
    if TaggableUser.count == 0 or TaggableArrayUser.count == 0
      puts "First you need to run writes task: 'rake bench:writes'"
    else
      puts_bench_name task_name

      trial_count = 1000
      data = create_fixtures trial_count
      skills = data.map{ |d| d[:skill] }
      skill_samplers = (0...trial_count).map{ skills.sample }

      Benchmark.bmbm do |x|
        x.report("Using Taggable") do
          skill_samplers.each do |skill|
            TaggableUser.tagged_with([skill], on: :skills)
          end
        end
        x.report("Using Postgres Arrays") do
          skill_samplers.each do |skill|
            TaggableArrayUser.with_any_skills([skill])
          end
        end
      end
    end
  end
end
