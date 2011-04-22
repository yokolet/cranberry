require 'fileutils'

class Thread
  def self.with_large_stack(stack_size_kb = 128, &block)
    r = proc do
      begin
        block.call
      rescue
        java.lang.System.out.println $!.message
        java.lang.System.out.println $!.backtrace.join("\n")
        raise $!
      end
    end
    t = java.lang.Thread.new(nil, r, "runWithLargeStack", stack_size_kb * 1024)
    t.start
    t
  rescue
    java.lang.System.out.println $!.message
    java.lang.System.out.println $!.backtrace.join("\n")
    raise $!
  end
end

PROJECT_DIR = File.expand_path('..', File.dirname(__FILE__))
SRC_DIR = "#{PROJECT_DIR}/scripts"
DATA_DIR = "#{PROJECT_DIR}/data"
GEM_DIR = "#{PROJECT_DIR}/vendor/gems/1.8"
ENV['GEM_PATH'] = GEM_DIR

FileUtils.mkdir_p(DATA_DIR)

Thread.with_large_stack{require 'rubygems'}.join
Thread.with_large_stack{require 'nokogiri'}.join
$: << SRC_DIR
