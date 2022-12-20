module Jekyll
  module Lilypond
    class TagProcessor
      attr_accessor :site

      def initialize(site, tag)
        @site = site
        @tag = tag
      end

      def source
        source_template_obj.render(@tag)
      end

      def source_template_obj
        Template.new(@site, @tag, :source)
      end

      def hash
        Digest::MD5.hexdigest(source)
      end

      def include
        trimmed = if @tag.attrs["trim"] == "true" then "_trimmed" else "" end
        @tag.attrs.update("filename" => hash + trimmed)
        @tag.attrs.update("baseurl" => @site.baseurl)
        include_template_obj.render(@tag)
      end

      def include_template_obj
        Template.new(@site, @tag, :include)
      end

      def file_processor
        FileProcessor.new("#{site.source}/lilypond_files", hash, source)
      end

      def file_already_registered(filename)
        for file in @site.static_files
          return true if file.basename == filename
        end
        return false
      end

      def run! 
        fp = file_processor
        fp.write
        fp.compile
        fp.trim_svg if @tag.attrs["trim"] == "true"
        fp.make_mp3 if @tag.attrs["mp3"] == "true"

        trimmed = if @tag.attrs["trim"] == "true" then "_trimmed" else "" end
        filename = hash + trimmed

        unless file_already_registered(filename)
          @site.static_files << StaticFile.new(site, 
                                               site.source, 
                                               "lilypond_files", 
                                               "#{filename}.svg") 
        end

        @site.static_files << StaticFile.new(site, 
                                             site.source, 
                                             "lilypond_files", 
                                             "#{hash}.mp3") if @tag.attrs["mp3"] == "true"
      end
    end
  end
end

