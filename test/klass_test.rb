require 'helper'
require 'dub/lua'

class KlassTest < Test::Unit::TestCase

  context 'A Klass' do
    setup do
      # namespacecv_xml = Dub.parse(fixture('app/xml/namespacedub.xml'))
      @class = namespacedub_xml[:dub][:Matrix]
    end

    should 'return a list of Functions with members' do
      assert_kind_of Array, @class.members
      assert_kind_of Dub::Function, @class.members.first
    end

    should 'return name with name' do
      assert_equal 'Matrix', @class.name
    end

    should 'have namespace prefix' do
      assert_equal 'dub', @class.prefix
    end

    should 'combine prefix and name in lib_name' do
      assert_equal 'dub_Matrix', @class.lib_name
    end

    should 'combine prefix and name in id_name' do
      assert_equal 'dub.Matrix', @class.id_name
    end

    should 'combine prefix and provided name in id_name' do
      assert_equal 'dub.Foobar', @class.id_name('Foobar')
    end

    should 'use parent namespace in full_type' do
      assert_equal 'dub::Matrix', @class.full_type
    end

    should 'return file and line on source' do
      assert_equal 'app/include/matrix.h:57', @class.source
    end

    should 'return a list of class methods' do
      assert_kind_of Array, @class.class_methods
    end

    context 'bound member list' do
      setup do
        Dub::Lua.bind(@class)
        @list = @class.members.map {|m| m.name}
      end

      should 'remove destructor from member list' do
        assert !@list.include?("~Matrix")
      end

      should 'remove constructor from member list' do
        assert !@list.include?("Matrix")
      end

      should 'ignore template methods in member list' do
        assert !@list.include?("give_me_tea")
      end

      should 'ignore members with templated arguments' do
        # at least for now
        assert !@list.include?("mul")
        assert_no_match %r{Matrix_mul}, @class.to_s
      end

      should 'ignore operator methods in member list' do
        assert !@list.include?("operator size_t")
      end
    end

    should 'return constructor with constructor' do
      const = @class.constructor
      assert_kind_of Dub::Function, const.first
    end

    should 'respond to destructor_name' do
      assert_equal 'Matrix_destructor', @class.destructor_name
    end

    should 'respond to tostring_name' do
      assert_equal 'Matrix__tostring', @class.tostring_name
    end

    should 'respond to constructor.method_name' do
      assert_equal 'Matrix_Matrix', @class.constructor.method_name(0)
    end

    should 'find method with array index' do
      assert_kind_of Dub::Function, @class[:rows]
    end

    should 'return header name on header' do
      assert_equal 'matrix.h', @class.header
    end

    should 'know that it is not a template' do
      assert !@class.template?
    end

    context 'bound to a generator' do
      setup do
        Dub::Lua.bind(@class)
      end

      should 'bind each member' do
        assert_equal Dub::Lua.function_generator, @class.members.first.gen
      end

      should 'register constructor' do
        assert_match %r{\{\s*\"Matrix\"\s*,\s*Matrix_Matrix\s*\}}, @class.to_s
      end

      should 'build constructor' do
        result = @class.to_s
        assert_match %r{static int Matrix_Matrix1\s*\(}, result
        assert_match %r{static int Matrix_Matrix2\s*\(}, result
        assert_match %r{static int Matrix_Matrix\s*\(},  result
      end

      should 'include class header' do
        assert_match %r{#include\s+"matrix.h"}, @class.to_s
      end

      should 'include helper header' do
        assert_match %r{#include\s+"lua_dub_helper.h"}, @class.to_s
      end

      should 'create Lua metatable with class name' do
        assert_match %r{luaL_newmetatable\(L,\s*"dub.Matrix"\)}, @class.to_s
      end

      should 'not build template methods' do
        assert_no_match %r{give_me_tea}, @class.to_s
      end

      should 'declare tostring' do
        assert_match %r{__tostring}, @class.to_s
      end

      should 'implement tostring' do
        assert_match %r{Matrix__tostring\(lua_State}, @class.to_s
      end
    end
  end

  context 'A template class' do
    setup do
      # namespacecv_xml = Dub.parse(fixture('app/xml/namespacedub.xml'))
      @class = namespacedub_xml[:dub].template_class(:TMat)
    end

    should 'know that it is a template' do
      assert @class.template?
    end

    should 'return template parameters' do
      assert_equal ['T'], @class.template_params
    end
  end

  context 'A class with alias names' do
    setup do
      # namespacecv_xml = Dub.parse(fixture('app/xml/namespacedub.xml'))
      @class = namespacedub_xml[:dub][:FloatMat]
    end

    should 'return a list of these alias on alias_names' do
      assert_equal ['FMatrix'], @class.alias_names
    end

    context 'bound to a generator' do
      setup do
        Dub::Lua.bind(@class)
      end

      should 'register all alias_names' do
        result = @class.to_s
        assert_match %r{"FloatMat"\s*,\s*FloatMat_FloatMat}, result
        assert_match %r{"FMatrix"\s*,\s*FloatMat_FloatMat}, result
        assert_match %r{luaL_register\(L,\s*"dub".*FloatMat_namespace_methods}, result
      end
    end
  end

  context 'A complex class' do
    setup do
      # namespacecv_xml = Dub.parse(fixture('app/xml/namespacedub.xml'))
      @class = namespacecv_xml[:cv][:Mat]
    end

    context 'bound to a generator' do
      setup do
        Dub::Lua.bind(@class)
      end

      should 'list all members on members' do
        assert_equal %w{addref adjustROI assignTo channels clone col colRange convertTo copyTo create cross depth diag dot elemSize elemSize1 empty eye isContinuous locateROI ones ptr release reshape row rowRange setTo size step1 type zeros}, @class.members.map {|m| m.name}
      end
    end
  end

  context 'A class with enums' do
    setup do
      # namespacecv_xml = Dub.parse(fixture('app/xml/namespacedub.xml'))
      @class = namespacecv_xml[:cv][:Mat]
    end

    should 'find a list of enums' do
      assert_equal %w{MAGIC_VAL AUTO_STEP CONTINUOUS_FLAG}, @class.enums
    end
  end
end
