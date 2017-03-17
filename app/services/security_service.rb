module Services
  class Security

    HASH_ITERATION = 50
    SALT_NUMBER_SIZE = 45
    MIN_SIZE_PWD = 5
    MAX_SIZE_PWD = 20

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

      def activate_account(options = {})
        if options[:new_password] != options[:confirm_password]
          raise Exceptions::NotAuthorizedException.new(
            I18n.translate 'activate_account.password.typo')
        elsif options[:new_password].size < MIN_SIZE_PWD || options[:new_password].size > MAX_SIZE_PWD
          raise Exceptions::NotAuthorizedException.new(
            I18n.translate(
              'activate_account.password.size',
              minimum: MIN_SIZE_PWD,
              maximum: MAX_SIZE_PWD
            )
          )
        end

        user = User.find_by registry: options[:registry]
        raise Exceptions::NotAuthorizedException.new(
          I18n.translate('activate_account.invalid_status')) if user.status != 'INACTIVE'

        user.password = options[:new_password]
        user.status = 'ACTIVE'
        user.status_note = nil

        user.save!
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