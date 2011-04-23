require 'ruboto'
require File.expand_path('config', File.dirname(__FILE__))
require File.expand_path('cranberry_entry', File.dirname(__FILE__))

java_import "android.text.util.Linkify"

ruboto_import_widgets :TextView, :LinearLayout, :Button

$activity.handle_create do |bundle|
  setTitle "Newfeeds by Nokogiri: #{Nokogiri::VERSION}"
  Thread.with_large_stack(256) do
    CranberryEntry.update
  end.join

  setup_content do
    linear_layout :orientation => LinearLayout::VERTICAL do
      @text_view = text_view :text => "What hath Matz wrought?", :id => 42
      @entries = CranberryEntry.class_variable_get(:@@entries)
      @entries.each do |entry|
        linear_layout :orientation => LinearLayout::VERTICAL, :padding => [0, 0, 0, 15] do
          linear_layout :orientation => LinearLayout::HORIZONTAL do
            text_view :text => "[#{entry.pubdate}]"
            text_view :text => entry.title, :padding => [10, 0, 0, 0]
          end
          url_text = text_view :text => entry.url
          Linkify.addLinks(url_text, Linkify::WEB_URLS)
          text_view :text => entry.description
        end
      end
      button :text => "M-x butterfly", :width => :wrap_content, :id => 43
    end
  end

  handle_click do |view|
    if view.getText == 'M-x butterfly'
      @text_view.setText "What hath Matz wrought! Nokogiri: #{Nokogiri::VERSION}"
      toast 'Flipped a bit via butterfly'
    end
  end
end
