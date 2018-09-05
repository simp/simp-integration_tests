require 'json'

module Simp
  module Beaker
    class NodesetHelpers
      def initialize(boxname)
        @boxname      = boxname
        @env_box      = "BEAKER_box__#{boxname}"
        @env_box_url  = "BEAKER_box_url__#{boxname}"
        @env_box_tree = 'BEAKER_box_tree'
      end

      def box_url
        test1 = ENV[@env_box] && ENV[@env_box_url]
        test2 = ENV[@env_box] && ENV[@env_box_tree]
        unless (box_url = test1 || test2)
          fail_with_env_var_instructions
        end
        box_url
      end

      def fail_with_env_var_instructions
          #FIXME: change 'warn' to 'fail'
          warn( <<MSG

--------------------------------------------------------------------------------
ERROR: SIMP Beaker integration tests set environment variables
--------------------------------------------------------------------------------

Either set these variables:

  #{@env_box}=simpci/BOX_NAME
  #{@env_box_tree}=/PATH/TO/BOX/TREE

Or set these variables:

  #{@env_box_urlBEAKER_box__#{boxname}=simpci/BOX_NAME
  BEAKER_box_url__#{boxname}=/PATH/TO/BOX_NAME.json

--------------------------------------------------------------------------------

MSG
          )
        end
      end
    end
  end
end
