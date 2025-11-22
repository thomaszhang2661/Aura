#!/usr/bin/env ruby
# add_files_to_xcode.rb
# 自动将文件添加到Xcode项目

require 'xcodeproj'

project_path = 'Aura.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# 获取主target
target = project.targets.first

# 需要添加的文件
files_to_add = [
  # Services文件
  { group: 'Aura/Services', file: 'ResourcesAPI.swift' },
  { group: 'Aura/Services', file: 'NetworkManager.swift' },
  { group: 'Aura/Services', file: 'APIConfigs.swift' },
  { group: 'Aura/Services', file: 'ResourcesService.swift' },
  
  # Resources Screen文件
  { group: 'Aura/Resources Screen', file: 'ResourceMapViewController.swift' },
  { group: 'Aura/Resources Screen', file: 'ResourceAnnotation.swift' },
  { group: 'Aura/Resources Screen', file: 'ResourceMapView.swift' },
]

puts "📦 开始添加文件到Xcode项目..."

files_to_add.each do |item|
  group_path = item[:group]
  filename = item[:file]
  
  # 查找或创建group
  group = project.main_group
  group_path.split('/').each do |path_component|
    next if path_component.empty?
    group = group[path_component] || group.new_group(path_component)
  end
  
  # 检查文件是否已存在
  existing_file = group.files.find { |f| f.path == filename }
  
  if existing_file
    puts "⏭️  跳过（已存在）: #{filename}"
  else
    # 添加文件引用
    file_ref = group.new_reference(filename)
    file_ref.last_known_file_type = 'sourcecode.swift'
    
    # 添加到编译阶段
    target.add_file_references([file_ref])
    
    puts "✅ 已添加: #{group_path}/#{filename}"
  end
end

# 保存项目
project.save

puts "\n🎉 完成！文件已添加到Xcode项目"
puts "📝 下一步: 在Xcode中 Clean Build Folder 然后重新编译"
