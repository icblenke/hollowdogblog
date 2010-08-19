module TinyDS
class PropertyDefinition
  def initialize(pname, ptype, opts)
    @pname = pname
    @ptype = ptype
    @opts  = opts
  end
  def default_value
    raise "no default." unless has_default?
    default = @opts[:default]
    case default
    when Proc
      default.call
    else
      default
    end
  end
  def has_default?
    @opts.has_key?(:default)
  end
  def to_ds_value(v)
    case @ptype
    when :string
      v.nil? ? nil : v.to_s
    when :integer
      v.nil? ? nil : v.to_i
    when :text
      v.nil? ? nil : com.google.appengine.api.datastore::Text.new(v.to_s)
    when :time
      case v
      when Time
        v
      when NilClass
        nil
      else
        raise "not Time value."
      end
    when :list
      case v
      when Array
        v.empty? ? nil : v
      when NilClass
        nil
      else
        raise "not Array value."
      end
    else
      raise "unknown property type '#{@ptype}'"
    end
  end
  def to_ruby_value(ds_v)
    case @ptype
    when :string
      ds_v.nil? ? nil : ds_v.to_s
    when :integer
      ds_v.nil? ? nil : ds_v.to_i
    when :text
      ds_v.nil? ? nil : ds_v.to_s
    when :time
      ds_v.nil? ? nil : ds_v
    when :list
      ds_v.nil? ? []  : ds_v.to_a
    else
      raise "unknown property type '#{@ptype}'"
    end
  end
end
end
