class UserCache

  def self.set(type, user, key, value)
    k = create_key(type, user, key)

    create_redis.set(k, value) rescue nil
  end

  def self.get(type, user, key)
    k = create_key(type, user, key)

    create_redis.get(k) rescue nil
  end

  def self.del(type, user, key)
    k = create_key(type, user, key)

    create_redis.del(k) rescue nil
  end

  private

  def self.create_key(type, user, key)
    "#{type}_#{user.id}:#{key}"
  end

  def self.create_redis
    @@redis ||= Redis.new
  end
end
