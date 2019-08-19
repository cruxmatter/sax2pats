module Sax2pats
  class XMLVersion4_1
    VERSION = '4.1'.freeze
    DATA_MAPPER_FILE = '4_1.yml'.freeze

    class << self
      def inventors_filter
        Proc.new do |inventors|
          inventors.select do |inventor|
            inventor.attributes['app-type'] == 'applicant-inventor'
          end
        end
      end
    end

    include Sax2pats::XMLVersion
  end
end
