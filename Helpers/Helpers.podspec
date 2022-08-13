Pod::Spec.new do |s|
s.name         = "Helpers"
s.version      = "0.0.1"
s.summary      = "Homework task"
s.homepage     = "http://www.test.page.com"
s.license      = { :type => "MIT", :file => "LICENSE" }
s.author    = "Vyacheslav Kusakin"

s.source = { :git => "/Helpers" }

s.source_files  = "Helpers/**/*.{swift}"
# s.resource  = "icon.png"
# s.resources = "Resources/*.png"
end
