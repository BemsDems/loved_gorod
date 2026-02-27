require 'xcodeproj'
project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first
group = project.main_group.find_subpath('Runner', true)
file_ref = group.new_reference('GoogleService-Info.plist')
target.add_resources([file_ref])
project.save
