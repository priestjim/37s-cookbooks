pkg = "ffmpeg_#{node[:ffmpeg][:version]}_amd64.deb"

package "libxvidcore4"
package "libfaac0"
package "libfaad0"
package "libmp3lame0"

dpkg_package "ruby-enterprise" do
  source "/home/system/pkg/debs/#{pkg}"
end