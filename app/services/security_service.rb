module Services
  class Security

    HASH_ITERATION = 50
    SALT_NUMBER_SIZE = 45

    class << self
      def audit_login(user, ip)
        Auditing.new do |a|
          a.user = user
          a.ip = ip
          a.event = 'LOGIN'
          a.event_date = Time.now
        end.save
      end

      def audit_logout(user, ip)
        Auditing.new do |a|
          a.user = user
          a.ip = ip
          a.event = 'LOGOUT'
          a.event_date = Time.now
        end.save
      end

      def generate_hash(raw_password, salt = nil)
        salt ||= self.generate_salt_number

        hash = ''
        HASH_ITERATION.times do
          hash = Digest::SHA512.base64digest("#{raw_password}#{salt}#{hash}")
        end

        hash
      end

      def generate_salt_number(seed = SALT_NUMBER_SIZE)
        salt = ''
        seed.times do
          salt << (
            i = Kernel.rand(62)
            i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))
          ).chr
        end
        
        salt
      end
    end
  end
end