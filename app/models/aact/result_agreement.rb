module Aact
class ResultAgreement < StudyRelationship
  self.table_name='result_agreements'

  def self.top_level_label
    '//certain_agreements'
  end

  def attribs
    {:pi_employee => get('pi_employee'),
     :agreement => get('restrictive_agreement'),
     :agreement_type => 'restrictive',
    }
  end

end
end
