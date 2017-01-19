module Services
  class Security

    HASH_ITERATION = 50
    SALT_NUMBER_SIZE = 45

    class << self
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