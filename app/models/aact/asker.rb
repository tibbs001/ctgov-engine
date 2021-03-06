require 'faraday'
require 'nokogiri'
require 'net/http'
require 'zip'

module Aact
	class Asker

		attr_accessor :existing_nct_ids, :should_refresh

		def existing_nct_ids
			@existing_nct_ids ||= Aact::Study.all.collect{|s|s.nct_id}
		end

		def self.create_all_studies(opts={})
			self.new.create_all_studies(opts)
		end

		def self.search_for_studies(opts={})
		  self.new.search_for_studies(opts)
		end

		def full_search(opts)
			if opts.class==String
				term=opts
				@should_refresh=true  #default to true
			else
			  term=opts[:term]
			  @should_refresh=opts[:should_refresh]
			end
			nct_ids=[]
			search_datestamp=Time.now
			zf="search_results/#{term}.zip"
			query_url="https://clinicaltrials.gov/search?term=#{term}&studyxml=true"
			results=Faraday.get(query_url)
			File.open(zf,'wb') {|file|file.write(results.body)}
			Zip::ZipFile.open(zf){|zip_file|
				zip_file.each {|f|
					nct_id=f.name.split('.').first
					create_study(nct_id)
				  create_search_result({:nct_id=>nct_id,:search_term=>term,:search_datestamp=>search_datestamp})
				}
      }
			nct_ids
		end

		def brief_search(opts)
			if opts.class==String
				term=opts
			  @should_refresh=true
			else
			  term=opts[:term]
			  @should_refresh=opts[:should_refresh]
			end
			search_datestamp=Time.now
			query_url="https://clinicaltrials.gov/search?term=#{term}&displayxml=true"
			nodes = Nokogiri::XML(call_to_ctgov(query_url)).xpath('//clinical_study')
			nodes.each{|node|
				nct_id=node.xpath('nct_id').inner_html
				order=node.xpath('order').inner_html
				score=node.xpath('score').inner_html
				create_study(nct_id)
				create_search_result({:nct_id=>nct_id,:search_term=>term,:search_datestamp=>search_datestamp,:order=>order,:score=>score})
			}
		end

		def create_all_studies(opts={})
			@should_refresh=opts[:should_refresh]
			collection=[]
			ctgov_pages.each {|page|
				tries=50
				query_url="https://clinicaltrials.gov/#{page}"
				Nokogiri::HTML(call_to_ctgov(query_url)).css('.layout_table').search('a').each { |link|
					nct_id=link['href'].split('/').last
					if !existing_nct_ids.include? nct_id
						create_study(nct_id)
					else
						msg='already exists'
						if should_refresh
	            log_event({:nct_id=>nct_id,:event_type=>'refresh',:status=>'active',:description=>msg})
							Study.where('nct_id=?',nct_id).first.destroy
							create_study(nct_id)
						else
	            log_event({:nct_id=>nct_id,:event_type=>'skipped',:status=>'complete',:description=>msg})
						end
					end
				}
			}
		end

		def get_study(nct_id)
			xml=Nokogiri::XML(Faraday.get("http://clinicaltrials.gov/show/#{nct_id}?resultsxml=true").body)
			Aact::StudyTemplate.new({:xml => xml,:nct_id=>nct_id})
		end

		def create_search_result(opts)
      e=log_event({:nct_id=>opts[:nct_id],:event_type=>'search_result',:status=>'active'})
			s=SearchResult.new(opts)
			s.save!
			complete_event(e)
			return s
		end

		def create_study(nct_id)
			begin
			  e=log_event({:nct_id=>nct_id,:event_type=>'create',:status=>'active'})
			  attribs=get_study(nct_id).attribs
			  study=Aact::Study.new.create_from(attribs)
			  existing_nct_ids << nct_id
				complete_event(e)
			  return study
			rescue => error
				msg="Failed: #{error}"
				puts msg
			  e.status='failed'
			  e.description=msg
				e.save!
			end
		end

		def log_event(opts={})
			puts "Event:  #{opts[:nct_id]}: #{opts[:event_type]} #{opts[:status]}  #{opts[:description]}"
			e=Aact::LoadEvent.new(:nct_id=>opts[:nct_id],:event_type=>opts[:event_type],:status=>opts[:status],:description=>opts[:description])
			e.save!
			e
		end

		def complete_event(event)
			event.status='complete'
			event.save!
    end

		def self.get(nct_id)
			self.new.get_study(nct_id)
		end

		def ctgov_pages
			collection=[]
			response = Faraday.get('https://clinicaltrials.gov/ct2/crawl').body
			Nokogiri::HTML(response).css('.layout_table').search('a').each { |link| collection << link['href'] }
			collection
		end

		def call_to_ctgov(query_url)
			begin
			  tries=50
				response = Faraday.get(query_url).body
			rescue => error
				tries = tries-1
				if tries > 0
					puts "> call to ct.gov failed.  #{error}  "
					sleep(5)
					retry
				else
					puts "Repeatedly tried: #{query_url}. Should I give up?"
				end
			end
	  end

  end
end
