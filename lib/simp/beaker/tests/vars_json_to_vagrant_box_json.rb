require 'json'

module Simp
  module Beaker
    class NodesetHelpers
      def fail_unless_env_vars_are_set_for(boxname)
        env_box      = "BEAKER_box__#{boxname}"
        env_box_url  = "BEAKER_box_url__#{boxname}"
        env_box_tree = 'BEAKER_box_tree'
        test1 = ENV[env_box] && ENV[env_box_url]
        test2 = ENV[env_box] && ENV[env_box_tree]

    require 'pry'; binding.pry
        unless test1 || test2
          ENV[var] || fail( "\n\n#{sep}\n" + <<MSG

--------------------------------------------------------------------------------
ERROR: SIMP Beaker integration tests must set the environment variable

  `#{var}`

  #{env}=/path/to/boxname.json

--------------------------------------------------------------------------------

MSG
          )
        end
      end
    end
  end
end
