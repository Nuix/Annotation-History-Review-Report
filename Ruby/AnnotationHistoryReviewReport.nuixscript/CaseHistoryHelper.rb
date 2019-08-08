# Nuix case history API only allows you to get an iterator for one type of
# history event at a time.  This class provides logic to get multiple types
# of history events and iterate over them in start date order as though they
# were in a single collection.
class CaseHistoryHelper
	include Enumerable

	def initialize(nuix_case,event_types)
		@nuix_case = nuix_case
		@event_types = event_types
	end

	def each
		iterators = {}
		@event_types.each do |event_type|
			iterators[event_type] = @nuix_case.getHistory({
				"type" => event_type,
			}).iterator
		end

		queue = []
		while iterators.any?{|event_type,iterator| iterator.hasNext} || queue.size > 0
			iterators.each do |event_type,iterator|
				if iterator.hasNext
					queue << iterator.next
				end
			end
			queue.sort_by!{|event| event.getStartDate.getMillis}
			yield queue.shift
		end
	end
end