module Sax2pats
  class Applicant
    include Entity
    attr_accessor :address,
                  :residence,
                  :nationality,
                  :orgname,
                  :first_name,
                  :last_name
  end
end
