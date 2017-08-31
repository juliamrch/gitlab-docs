desc 'Pulls down the CE, EE, Omnibus and Runner git repos and merges the content of their doc directories into the nanoc site'
task :pull_repos do
  require 'yaml'

  # By default won't delete any directories, requires all relevant directories
  # be empty. Run `RAKE_FORCE_DELETE=true rake pull_repos` to have directories
  # deleted.
  force_delete = ENV['RAKE_FORCE_DELETE']

  # Parse the config file and create a hash.
  config = YAML.load_file('./nanoc.yaml')

  # Pull products data from the config.
  ce = config["products"]["ce"]
  ee = config["products"]["ee"]
  omnibus = config["products"]["omnibus"]
  runner = config["products"]["runner"]

  products = [ce, ee, omnibus, runner]
  dirs = []
  products.each do |product|
    dirs.push(product['dirs']['temp_dir'])
    dirs.push(product['dirs']['dest_dir'])
  end

  if force_delete
    puts "WARNING: Are you sure you want to remove #{dirs.join(', ')}? [y/n]"
    exit unless STDIN.gets.index(/y/i) == 0

    dirs.each do |dir|
      puts "\n=> Deleting #{dir} if it exists\n"
      FileUtils.rm_r("#{dir}") if File.exist?("#{dir}")
    end
  else
    puts "NOTE: The following directories must be empty otherwise this task " +
      "will fail:\n#{dirs.join(', ')}"
    puts "If you want to force-delete the `tmp/` and `content/` folders so \n" +
      "the task will run without manual intervention, run \n" +
      "`RAKE_FORCE_DELETE=true rake pull_repos`."
  end

  dirs.each do |dir|
    unless "#{dir}".start_with?("tmp")
      puts "\n=> Making an empty #{dir}"
      FileUtils.mkdir("#{dir}") unless File.exist?("#{dir}")
    end
  end

  puts "\n=> Setting up dummy user/email in Git"

  `git config --global user.name "John Doe"`
  `git config --global user.email johndoe@example.com`

  products.each do |product|
    temp_dir = File.join(product['dirs']['temp_dir'])

    case product['slug']
    when 'ce'
      branch = ENV['BRANCH_CE'] || 'master'
    when 'ee'
      branch = ENV['BRANCH_EE'] || 'master'
    when 'omnibus'
      branch = ENV['BRANCH_OMNIBUS'] || 'master'
    when 'runner'
      branch = ENV['BRANCH_RUNNER'] || 'master'
    end

    if !File.exist?(temp_dir) || Dir.entries(temp_dir).length.zero?
      puts "\n=> Cloning #{product['repo']} #{branch} into #{temp_dir}\n"

      `git clone #{product['repo']} #{temp_dir} --depth 1 --branch #{branch}`
    elsif File.exist?(temp_dir) && !Dir.entries(temp_dir).length.zero?
      puts "\n=> Pulling #{branch} of #{product['repo']}\n"

      # Enter the temporary directory and return after block is completed.
      FileUtils.cd(temp_dir) do
        # Update repository from master.
        `git pull origin #{branch}`
      end
    else
      puts "This shouldn't happen"
    end

    temp_doc_dir = File.join(product['dirs']['temp_dir'], product['dirs']['doc_dir'], '.')
    destination_dir = File.join(product['dirs']['dest_dir'])
    puts "\n=> Copying #{temp_doc_dir} into #{destination_dir}\n"
    FileUtils.cp_r(temp_doc_dir, destination_dir)
  end
end
