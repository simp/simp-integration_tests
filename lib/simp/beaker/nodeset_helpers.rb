require 'json'

module Simp
  module Beaker
    class NodesetHelpers
      def initialize(hostname)
        @env_box_name = "BEAKER_box__#{hostname}"
        @env_box_url  = "BEAKER_box_url__#{hostname}"
        @env_box_tree = 'BEAKER_box_tree'
      end

      def box_url_from__env_box_url
        if (box_url = ENV[@env_box_url])
          if box_url =~ %r(^/)
            box_url = "file://#{box_url}"
          end
          warn '', '-' * 80, "box_url = '#{box_url}'", '-' * 80, ''
          return box_url
        end
      end

      def box_url_from__env_box_tree
        box_tree = ENV[@env_box_tree]
        @box_name = ENV[@env_box_name]
        unless box_tree.empty? || box_name.empty?
          box_tree = "file://#{box_tree}" if box_tree =~ %r(^/)
          @box_url = File.expand_path("#{@box_name}.json", box_tree)
          warn '', '-' * 80, '', "box_url = '#{@box_url}'", '', '-' * 80, ''
          return @box_url
        end
      end

      # return the proper box_url or fail with instructions
      def box_url
        return box_url_from__env_box_url if box_url_from__env_box_url
        return box_url_from__env_box_tree if box_url_from__env_box_tree
        fail_with_env_var_instructions
      end

      def box_name
        return ENV[@env_box_name] if ENV[@env_box_name]
        unless (box_url = box_url_from__env_box_url)
          fail_with_env_var_instructions
        end
        File.basename(box_url).sub(/\.json$/i,'')
      end

      def fail_with_env_var_instructions
        fail(<<MSG
--------------------------------------------------------------------------------
ERROR: SIMP Beaker integration tests set environment variables
--------------------------------------------------------------------------------

Either set these variables:

  #{@env_box_name}=simpci/BOX_NAME
  #{@env_box_tree}=/PATH/TO/BOX/TREE

Or set these variables:

  #{@env_box_url}=/PATH/TO/BOX_NAME.json

--------------------------------------------------------------------------------

MSG
            )
      end
    end
  end
end
