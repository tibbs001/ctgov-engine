class CreateResults < ActiveRecord::Migration
  def change

    create_table :result_contacts do |t|
      t.string :name_or_title
      t.string :organization
      t.string :phone
      t.string :email
    end
    add_column :result_contacts, :nct_id, :string, references: :studies

    create_table :result_agreements do |t|
      t.string :pi_employee
      t.string :agreement
      t.string :agreement_type
    end
    add_column :result_agreements, :nct_id, :string, references: :studies

    create_table :baseline_measures do |t|
      t.string  :ctgov_group_id
      t.integer :ctgov_group_enumerator
      t.string  :category
      t.string  :title
      t.text    :description
      t.string  :units
      t.string  :param
      t.string  :measure_value
      t.string  :lower_limit
      t.string  :upper_limit
      t.string  :dispersion
      t.string  :spread
      t.text    :measure_description
    end
    add_column :baseline_measures, :nct_id, :string, references: :studies

    create_table :result_details do |t|
      t.text :recruitment_details
      t.text :pre_assignment_details
    end
    add_column :result_details, :nct_id, :string, references: :studies

    create_table :periods do |t|
      t.string :title
    end
    add_column :periods, :nct_id, :string, references: :studies

    create_table :milestones do |t|
      t.string  :ctgov_group_id
      t.integer :ctgov_group_enumerator
      t.string  :title
      t.string  :description
      t.integer :participant_count
    end
    add_column :milestones, :nct_id, :string, references: :studies
    add_column :milestones, :period_id, :integer, references: :periods

    create_table :drop_withdrawals do |t|
      t.string  :ctgov_group_id
      t.integer :ctgov_group_enumerator
      t.string  :reason
      t.integer :participant_count
    end
    add_column :drop_withdrawals, :nct_id, :string, references: :studies
    add_column :drop_withdrawals, :period_id, :integer, references: :periods

    create_table :actual_outcomes do |t|
      t.string  :ctgov_group_id
      t.integer :ctgov_group_enumerator
      t.text    :group_title
      t.text    :group_description
      t.string  :outcome_type
      t.string  :title
      t.text    :description
      t.string  :measure
      t.string  :time_frame
      t.string  :safety_issue
      t.string  :population
      t.integer :participant_count
    end
    add_column :actual_outcomes, :nct_id, :string, references: :studies

    create_table :outcome_measures do |t|
      t.string  :ctgov_group_id
      t.integer :ctgov_group_enumerator
      t.string  :category
      t.string  :title
      t.text    :description
      t.string  :units
      t.string  :param
      t.string  :measure_value
      t.string  :lower_limit
      t.string  :upper_limit
      t.string  :dispersion
      t.string  :spread
      t.string  :measure_description
   end
    add_column :outcome_measures, :nct_id, :string, references: :studies
    add_column :outcome_measures, :actual_outcome_id, :integer, references: :actual_outcomes

    create_table :outcome_analyses do |t|
      t.string  :ctgov_group_id
      t.integer :ctgov_group_enumerator
      t.string  :title
      t.string  :non_inferiority
      t.string  :non_inferiority_description
      t.string  :p_value
      t.string  :param_type
      t.string  :param_value
      t.string  :ci_percent
      t.string  :ci_n_sides
      t.string  :ci_lower_limit
      t.string  :ci_upper_limit
      t.string  :method
      t.text    :description
      t.text    :group_description
      t.text    :method_description
      t.text    :estimate_description
    end
    add_column :outcome_analyses, :nct_id, :string, references: :studies
    add_column :outcome_analyses, :actual_outcome_id, :integer, references: :actual_outcomes

    create_table :reported_events do |t|
      t.string   :ctgov_group_id
      t.integer  :ctgov_group_enumerator
      t.string   :group_title
      t.string   :group_description
      t.string   :description
      t.string   :time_frame
      t.string   :category
      t.string   :event_type
      t.string   :frequency_threshold
      t.string   :default_vocab
      t.string   :default_assessment
      t.string   :title
      t.integer  :subjects_affected
      t.integer  :subjects_at_risk
      t.integer  :event_count
    end
    add_column :reported_events, :nct_id, :string, references: :studies

    create_table :reported_event_overviews do |t|
      t.string :time_frame
      t.text   :description
    end
    add_column :reported_event_overviews, :nct_id, :string, references: :studies

    create_table :actual_groups do |t|
      t.string  :ctgov_group_id
      t.integer :ctgov_group_enumerator
      t.string  :group_type
      t.string  :title
      t.string  :description
      t.integer :participant_count
    end
    add_column :actual_groups, :nct_id, :string, references: :studies

  end
end
