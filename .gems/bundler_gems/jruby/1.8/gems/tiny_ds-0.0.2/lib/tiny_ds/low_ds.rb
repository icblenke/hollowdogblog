require 'appengine-apis/datastore'

module TinyDS
module LowDS
  KeyFactory = com.google.appengine.api.datastore.KeyFactory

  # build
  def self.build(kind, attrs, opts={})
    raise "invalid kind=#{kind}" unless kind.kind_of?(String)
    raise "invalid opts=#{opts.inspect}" if [:id, :name, :key].collect{|k| opts[k] }.compact.size >= 2
    raise ":id must be Integer"  if opts[:id]   && !opts[:id].kind_of?(Integer)
    raise ":name must be String" if opts[:name] && !opts[:name].kind_of?(String)
    raise ":key must be Key or String" if opts[:key] && !(opts[:key].kind_of?(String) || opts[:key].kind_of?(AppEngine::Datastore::Key))
    name_or_id = opts[:name] || opts[:id] # name(String) or id(Integer)
    key        = opts[:key].kind_of?(String) ? KeyFactory.stringToKey(opts[:key]) : opts[:key]
    parent     = opts[:parent]
    ent = if key
            AppEngine::Datastore::Entity.new(key)
          elsif parent
            parent_key = case parent
                         when AppEngine::Datastore::Entity; parent.key
                         when AppEngine::Datastore::Key;    parent
                         when String; KeyFactory.stringToKey(parent)
                         else raise "invalid parent type parent=[#{parent.inspect}]"
                         end
            if name_or_id
              new_key = KeyFactory.createKey(parent_key, kind, name_or_id)
              AppEngine::Datastore::Entity.new(new_key)
            else
              AppEngine::Datastore::Entity.new(kind, parent_key)
            end
          else
            if name_or_id
              new_key = KeyFactory.createKey(kind, name_or_id)
              AppEngine::Datastore::Entity.new(new_key)
            else
              AppEngine::Datastore::Entity.new(kind)
            end
          end
    attrs.each do |k,v|
      ent[k] = v
    end
    ent
  end

  # create
  def self.create(kind, attrs, opts={})
    ent = build(kind, attrs, opts)
    AppEngine::Datastore.put(ent)
    ent
  end

  # get by key
  def self.get(key, opts={})
    key = case key
          when AppEngine::Datastore::Key; key
          when String; KeyFactory.stringToKey(key)
          else raise "invalid key type key.class=[#{key.class}] key.inspect=[#{key.inspect}]"
          end
    ent = AppEngine::Datastore.get(key)
    if opts[:kind]
      raise "kind missmatch. #{ent.kind}!=#{opts[:kind]}" if ent.kind!=opts[:kind]
    end
    ent
  end

  # update
  def self.save(ent)
    AppEngine::Datastore.put(ent)
  end

  # delete
  def self.delete(ent)
    AppEngine::Datastore.delete([ent.key])
  end
end
end
