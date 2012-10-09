#!/usr/local/bin/ruby

require 'fileutils'

class BackupUtil
  MYSQL_ROOT="/u/mysql"
  BACKUP_ROOT="/u/backup/mysql"

  attr_reader :application, :backup_path, :current_path, :defaults_file, :mysql_defaults, :databases
  
  def initialize(application)
    @application = application
    @backup_path = File.join(BACKUP_ROOT, application)
    @current_path = File.join(backup_path, "current")
    @defaults_file = File.join(MYSQL_ROOT, application, "config", "my.cnf")
    @mysql_defaults = {}
    @databases = [ 'mysql', 'test', "#{application}_production" ]

    parse_defaults

    unless File.exist?(backup_path)
      STDERR.puts "Usage: #{$0} <application>"
      exit(1)
    end
  end

  def run
    rotate_current

    # Copy table definitions as well as MyISAM tables to the backup dir
    Dir[File.join(mysql_defaults['datadir'], '*')].each do |db|
      next unless databases.include?(File.basename(db))
      dest_dir = File.join(current_path, 'tables', File.basename(db))
      FileUtils.mkdir_p(dest_dir)
      files = %w(*.frm *.MYI *.MYD).map { |ext| Dir.glob(File.join(db, ext)) }.flatten
      files.each do |file|
        FileUtils.cp(file, File.join(dest_dir, File.basename(file)))
      end
    end

    # Do hot backup of InnoDB
    system("/usr/bin/xtrabackup --defaults-file=#{defaults_file} --target-dir=#{current_path} --backup 2>&1 | tee #{current_path}/backup.log")
  end

  def parse_defaults
    File.readlines(defaults_file).each do |line|
      data = line.chomp.split(/\s*=\s*/)
      mysql_defaults[data[0]] = data[1]
    end
  end
    
  def rotate_current
    if stat = File.stat(current_path)
      FileUtils.mv(current_path, get_new_filename(File.join(backup_path, stat.ctime.strftime('%Y%m%d'))))
    end
  rescue Errno::ENOENT
    # no current directory present, not a problem, we'll create it below
  ensure
    FileUtils.mkdir_p(current_path)
  end

  def get_new_filename(path)
    if File.exist?(path)
      (base, suffix) = path.split('.')
      suffix = suffix.to_i
      suffix += 1
      get_new_filename("#{base}.#{suffix}")
    else
      path
    end
  end
end

backup = BackupUtil.new(ARGV[0])
backup.run
