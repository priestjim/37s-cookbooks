package "gitosis"

user "gitosis" do
  action :remove
end

group "gitosis" do
  action :remove
end

# Install local modifications to Gitosis
%W(access.py serve.py).each do |patched|
  cookbook_file "/usr/share/pyshared/gitosis/#{patched}" do
    source "#{patched}"
    owner "root"
    group "root"
    mode 0755
  end
end
