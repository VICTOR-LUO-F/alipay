module Alipay
  module Sign
    def self.generate(params, options = {})
      params = Utils.stringify_keys(params)
      sign_type = options[:sign_type] || Alipay.sign_type
      key = options[:key] || Alipay.key
      string = params_to_string(params)

      case sign_type
      when 'MD5'
        MD5.sign(key, string)
      when 'RSA'
        RSA.sign(key, string)
      when 'DSA'
        DSA.sign(key, string)
      else
        raise ArgumentError, "invalid sign_type #{sign_type}, allow value: 'MD5', 'RSA', 'DSA'"
      end
    end

    ALIPAY_RSA_PUBLIC_KEY = <<-EOF
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnxj/9qwVfgoUh/y2W89L6BkRA
FljhNhgPdyPuBV64bfQNN1PjbCzkIM6qRdKBoLPXmKKMiFYnkd6rAoprih3/PrQE
B/VsW8OoM8fxn67UDYuyBTqA23MML9q1+ilIZwBC2AQ2UBVOrFXfFl75p6/B5Ksi
NG9zpgmLCUYuLkxpLQIDAQAB
-----END PUBLIC KEY-----
    EOF

    ALIPAY_RSA_APP_PAY_PUBLIC_KEY = <<-EOF
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDDI6d306Q8fIfCOaTXyiUeJHkr
IvYISRcc73s3vF1ZT7XN8RNPwJxo8pWaJMmvyTn9N4HQ632qJBVHf8sxHi/fEsra
prwCtzvzQETrNRwVxLO5jVmRGi60j8Ue1efIlzPXV9je9mkjzOmdssymZkh2QhUr
CmZYI/FCEa3/cNMW0QIDAQAB
-----END PUBLIC KEY-----
    EOF

    def self.verify?(params, options = {})
      params = Utils.stringify_keys(params)

      sign_type = params.delete('sign_type')
      sign = params.delete('sign')
      string = params_to_string(params)

      case sign_type
      when 'MD5'
        key = options[:key] || Alipay.key
        MD5.verify?(key, string, sign)
      when 'RSA'
        RSA.verify?(ALIPAY_RSA_PUBLIC_KEY, string, sign)
      when 'DSA'
        DSA.verify?(string, sign)
      else
        false
      end
    end

    def self.app_pay_verify?(params, options = {})
      params = Utils.stringify_keys(params)

      sign_type = params.delete('sign_type')
      sign = params.delete('sign')
      string = params_to_string(params)

      case sign_type
      when 'MD5'
        key = options[:key] || Alipay.key
        MD5.verify?(key, string, sign)
      when 'RSA'
        RSA.verify?(ALIPAY_RSA_APP_PAY_PUBLIC_KEY, string, sign)
      when 'DSA'
        DSA.verify?(string, sign)
      else
        false
      end
    end

    def self.params_to_string(params)
      params.sort.map { |item| item.join('=') }.join('&')
    end
  end
end
