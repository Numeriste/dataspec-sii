require 'json'
require 'csv'
require 'pry'

class ProcessTransfers
  def initialize(file)
    @data = CSV.table(file).map{|row| row.to_hash}
    @out_data = Array.new
  end

  # Process transfer data for display
  def process
    @data.each do |item|
      item[:goods] = item[:goods__laser_acoustic_detection_equipment__intrusion_software__network_infrastructure_and_services__off_the_air_interception__monitoring_centres__lawful_interception_mediation__deep_packet_inspection__forensics__biometrics__fibre_taps__probes__location_tracking__internet_filters]
      item[:source_links] = extract_links(item[:sources])
      item[:title] = gen_title(item)
      item[:unique_id] = gen_id(item)
      @out_data.push(item)
    end

    JSON.pretty_generate(@out_data)
  end

  # Generate an item ID
  def gen_id(item)
    id_str = item[:supplier_company].to_s.gsub(" ", "_")+"_"+item[:recipient_country].to_s+"_"+item[:order_year].to_s
    return id_str.gsub("/", "").gsub("(", "").gsub(")", "").gsub(",", "").gsub(".", "")
  end

  # Generate the item title, with different options for different fields present
  def gen_title(item)
    if item[:supplier_company] && item[:recipient_country]
      return item[:supplier_company] + " Sales to " + item[:recipient_country]
    elsif !item[:supplier_company] && item[:recipient_country] && item[:goods]
      return item[:recipient_country] + " Purchase of " + item[:goods] + " Techology"
    elsif item[:supplier_company] && !item[:recipient_country] && item[:goods]
      return item[:supplier_company] + " Sales of " + item[:goods] + " Technology"
    elsif item[:recipient_country] && item[:order_year]
      return item[:recipient_country] + " Purchase in " + item[:order_year].to_s
    end
  end

  # Extract links from an item and field
  def extract_links(field)
    return field.split("<").select{|f| f.include?(">")}.map{|i| i.split(">")[0]}
  end
end
