module Aact
class OversightAuthority < StudyRelationship
  self.table_name='oversight_authorities'

  def self.top_level_label
    '//oversight_info'
  end

  def self.create_all_from(opts)
    nct_id=opts[:nct_id]
    xml=opts[:xml].xpath("//oversight_info").children
    (xml.collect {|node| 
      self.new({:name=>node.text,:nct_id=>nct_id}) if node.name=='authority'}).compact
  end
    
end
end
