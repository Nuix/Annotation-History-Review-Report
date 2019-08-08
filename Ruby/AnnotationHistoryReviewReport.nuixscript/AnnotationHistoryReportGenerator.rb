# This class generates a series of HTML files that together constitute a report of
# annotation and export events in a Nuix case and some information about the items
# involved in those events.
# The report is generated in three levels:

# - Event Summary: This report lists all the annotation and export events found in the case.  Each event listed has a hyper link to an Event Details report.
# - Event Details: Generated for each event.  Lists the items affected by the given event.  Each listed item has a hyper link to an Item Details report.
# - Item Details: For each item involved in an event, lists some high level details about that item and the history events that given item was involved in.

class AnnotationHistoryReportGenerator
	require 'erb'
	include ERB::Util
	require 'fileutils'

	def initialize(output_directory)
		# Get output directories setup
		@output_directory = output_directory
		java.io.File.new(output_directory).mkdirs
		output_css_directory = File.join(output_directory,"Resources","css")
		output_js_directory = File.join(output_directory,"Resources","js")
		java.io.File.new(output_css_directory).mkdirs
		java.io.File.new(output_js_directory).mkdirs

		# Copy resources to report directory
		script_directory = File.dirname(__FILE__)
		resources_directory = File.join(script_directory,"Resources")
		css_directory = File.join(resources_directory,"css")
		js_directory = File.join(resources_directory,"js")

		FileUtils.cp(File.join(css_directory,"bootstrap.min.css"),File.join(output_css_directory,"bootstrap.min.css"))
		FileUtils.cp(File.join(js_directory,"bootstrap.min.js"),File.join(output_js_directory,"bootstrap.min.js"))

		@date_format = "YYYY/MM/dd HH:mm:ss z"
		@time_zone = org.joda.time.DateTime.new.getZone

		@script_directory = File.dirname(__FILE__)

		event_summary_template_file = File.join(@script_directory,"EventSummaryTemplate.erb")
		@event_summary_erb = ERB.new(File.read(event_summary_template_file))

		event_detail_template_file = File.join(@script_directory,"EventDetailsTemplate.erb")
		@event_detail_erb = ERB.new(File.read(event_detail_template_file))

		item_detail_template_file = File.join(@script_directory,"ItemDetailsTemplate.erb")
		@item_detail_erb = ERB.new(File.read(item_detail_template_file))

		@item_detail_cache = {}
	end

	def generate_report(nuix_case,progress_dialog)
		@progress_dialog = progress_dialog
		@item_detail_cache = {}
		@next_event_id = 0

		events = CaseHistoryHelper.new(nuix_case,["annotation","export"])
		
		event_summary_file = File.join(@output_directory,"AnnotationEventReport.html")
		event_summary_result = @event_summary_erb.result(binding)

		File.open(event_summary_file,"w:utf-8") do |summary_html|
			summary_html.puts(event_summary_result)
		end

		@progress_dialog.logMessage("Report Directory: #{@output_directory}")
		@progress_dialog = nil
	end

	# Looking to report events associated with
	# - Tag Add or Remove
	# - Excluded or Included
	# - Comments Set or Clear
	# - Custom Metadata Set or Removed
	def get_operation_description(event)
		details = event.getDetails

		if event.getTypeString == "export"
			return "Export Ran"
		else
			if details.has_key?("tag")
				tag = details["tag"]
				added = details["added"] == true
				return "Tag '#{tag}' #{added ? "Added" : "Removed"}"
			end

			if details.has_key?("fieldName")
				fieldName = details["fieldName"]
				set = details.has_key?("value")
				return "Custom Metdata Field '#{fieldName}' #{set ? "Set" : "Removed"}"
			end

			if details.has_key?("comment")
				cleared = details["comment"].nil? || details["comment"].strip.empty?
				return "Comment #{cleared ? "Removed" : "Set"}"
			end

			if details.has_key?("excluded")
				was_excluded = details["excluded"] == true
				if was_excluded
					return "Exclusion '#{details["exclusion"]}' Applied"
				else
					return "Exclusion Removed"
				end
			end

			if details.has_key?("productionSet")
				production_set = details["productionSet"]
				if details.has_key?("added")
					added = details["added"] == true
					item_count = details["itemCount"] || 0
					return "#{added ? "Added to" : "Removed from"} production set '#{production_set}'"
				else
					return "Production Set"
				end
			end
		end
	end

	def event_detail_relative_path(event)
		date = event.getStartDate
		year = date.toString("YYYY")
		month = date.toString("MM")
		day = date.toString("dd")
		hour = date.toString("HH")
		start_millis = date.getMillis
		finish_millis = event.getEndDate.getMillis
		@next_event_id += 1

		File.join("EventDetails",year,month,day,hour,"#{@next_event_id.to_s.rjust(10,"0")}.html")
	end

	def generate_event_details(event)
		rel_file = event_detail_relative_path(event)
		abs_file = File.join(@output_directory,rel_file)
		java.io.File.new(abs_file).getParentFile.mkdirs
		result = @event_detail_erb.result(binding)
		File.open(abs_file,"w:utf-8") do |event_detail_html|
			event_detail_html.puts(result)
		end
		return rel_file
	end

	def item_detail_relative_path(item)
		guid = item.getGuid
		if !@item_detail_cache.has_key?(guid)
			@item_detail_cache[guid] = generate_item_details(item)
		end
		return @item_detail_cache[guid]
	end

	def generate_item_details(item)
		guid = item.getGuid.gsub("-","")
		chunk_a = guid[0..3]
		chunk_b = guid[4..6]
		chunk_c = guid[7..9]
		rel_file = File.join("ItemDetails",chunk_a,chunk_b,chunk_c,"#{guid}.html")
		abs_file = File.join(@output_directory,rel_file)
		java.io.File.new(abs_file).getParentFile.mkdirs
		result = @item_detail_erb.result(binding)
		File.open(abs_file,"w:utf-8") do |item_detail_html|
			item_detail_html.puts(result)
		end
		return "../../../../../"+rel_file
	end
end