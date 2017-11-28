require './lib/task_helpers'

task :default => [:setup_repos, :setup_content_dirs, :pull_repos]

task :setup_git do
  puts "\n=> Setting up dummy user/email in Git"

  `git config --global user.name "John Doe"`
  `git config --global user.email johndoe@example.com`
end

desc 'Setup repositories for CE, EE, Omnibus and Runner in special way exposing only their doc directories'
task :setup_repos do
  products.each_value do |product|
    next if File.exist?(product['dirs']['temp_dir'])

    puts "\n=> Setting up repository #{product['repo']} into #{product['dirs']['temp_dir']}\n"
    `git init #{product['dirs']['temp_dir']}`

    Dir.chdir(product['dirs']['temp_dir']) do
      `git remote add origin #{product['repo']}`

      # Configure repository for sparse-checkout
      `git config core.sparsecheckout true`
      File.open('.git/info/sparse-checkout', 'w') { |f| f.write("/#{product['dirs']['doc_dir']}/*") }
    end
  end
end

desc 'Setup content directories by symlinking to the repositories documentation folder'
task :setup_content_dirs do
  products.each_value do |product|
    source = File.join('../', product['dirs']['temp_dir'], product['dirs']['doc_dir'])
    target = product['dirs']['dest_dir']

    next if File.symlink?(target)

    puts "\n=> Setting up content directory for #{product['repo']}\n"

    `ln -s #{source} #{target}`
  end
end

desc 'Pulls down the CE, EE, Omnibus and Runner git repos fetching and keeping only the most recent commit'
task :pull_repos do
  products.each_value do |product|
    branch = retrieve_branch(product['slug'])

    puts "\n=> Pulling #{branch} of #{product['repo']}\n"

    # Enter the temporary directory and return after block is completed.
    Dir.chdir(product['dirs']['temp_dir']) do
      `git fetch origin #{branch} --depth 1`

      # Stash modified and untracked files so we have "clean" environment
      # without accidentally deleting data
      `git stash -u` if git_workdir_dirty?
      `git checkout #{branch}`
    end
  end
end
