require 'html-proofer'
require 'html/pipeline'
# rake test
desc "build and test website"
task :test do
  FileUtils.rm_rf('_site',:verbose => true)
  sh "bundle exec jekyll build -d _site/etc"
  HTMLProofer.check_directory("./_site", {:href_ignore=> ['http://localhost:4000'], :verbose => true}).run
end
