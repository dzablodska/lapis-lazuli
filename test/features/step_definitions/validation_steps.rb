################################################################################
# Copyright 2014 spriteCloud B.V. All rights reserved.
# Generated by LapisLazuli, version 0.0.1
# Author: "Onno Steenbergen" <onno@steenbe.nl>

require 'lapis_lazuli'
require 'test/unit/assertions'

include Test::Unit::Assertions

ll = LapisLazuli::LapisLazuli.instance

Then(/(first|last|random|[0-9]+[a-z]+) (.*) should (not )?be the (first|last|[0-9]+[a-z]+) element on the page$/) do |index, type, differ, location_on_page|
	# Convert the type text to a symbol
	type = type.downcase.gsub(" ","_")

	pick = 0
	if ["first","last","random"].include?(index)
		pick = index.to_sym
	else
		pick = index.to_i - 1
	end
	# Options for find
	options = {}
	# Select the correct element
	options[type.to_sym] = {}
	# Pick the correct one
	options[:pick] = pick
	# Execute the find
	type_element = ll.browser.find(options)

	# All elements on the page
	body_elements = ll.browser.body.elements
	# Find the element we need
	page_element = nil
	if location_on_page == "first"
		page_element = body_elements.first
	elsif location_on_page == "last"
		page_element = body_elements.last
	else
		page_element = body_elements[location_on_page.to_i - 1]
	end

	# No page element
	if not page_element
		ll.error("Could not find an element on the page")
	# Elements are the same but it should not be
	elsif page_element == type_element and differ
		ll.error("Elements on the page are the same")
	# Elements are different but should be the same
	elsif page_element != type_element and not differ
		ll.error("Elements should be the same")
	end
end

Then(/(first|last|random|[0-9]+[a-z]+) (.*) should (not )?be present$/) do |index, type, hidden|
  # Convert the type text to a symbol
	type = type.downcase.gsub(" ","_")

	pick = 0
	if ["first","last","random"].include?(index)
		pick = index.to_sym
	else
		pick = index.to_i - 1
	end

	# Options for findAll
	options = {:present => false}
	# Select the correct element
	options[type.to_sym] = {}
	# Pick the correct one
	options[:pick] = pick
	# Execute the find
	type_element = ll.browser.find(options)
	# Find all
	all_elements = ll.browser.findAll(options)
	all_present = ll.browser.findAllPresent(options)

	if hidden and type_element.present?
		ll.error("Hidden element is visible")
	elsif not hidden and not type_element.present?
		ll.error("Element is hidden")
	elsif hidden and not type_element.present? and
		(not all_elements.include?(type_element) or all_present.include?(type_element))
		ll.error("Hidden element (not) found via findAll(Present)")
	elsif not hidden and type_element.present? and
		(not all_elements.include?(type_element) or not all_present.include?(type_element))
		ll.error("Visible element (not) found via findAll(Present)")
	end
end

Then(/^within (\d+) seconds I should see "([^"]+?)"( disappear)?$/) do |timeout, text, condition|
  if condition
		condition = :while
	else
		condition = :until
	end

	ll.browser.wait(
		:timeout => timeout,
		:text => text,
		:condition => condition,
		:groups => ["wait"]
	)
end

Then(/^within (\d+) seconds I should see "([^"]+?)" and "([^"]+?)"( disappear)?$/) do |timeout, first, second, condition|
	if condition
		condition = :while
	else
		condition = :until
	end

	ll.browser.wait_multiple(
		:timeout => timeout,
		:condition => condition,
		:operator => :all_of,
		:groups => ["wait"],
		:list => [
			{ :tag_name => 'span', :class => /foo/ },
			{ :tag_name => 'div', :id => 'bar' }
		]
	)
end

Then(/^within (\d+) seconds I should see added elements with matching$/) do |timeout|
	elems = ll.browser.wait_multiple(
		:timeout => timeout,
		:condition => :until,
		:operator => :all_of,
		:groups => ["wait"],
		:list => [
			{ :tag_name => 'span', :class => /foo/, :text => /foo/ },
			{ :tag_name => 'div', :id => 'bar', :html => "bar" }
		]
	)
 	assert 2 == elems.length
end

Then(/^within 10 seconds I should see either added element/) do
	ll.browser.wait_multiple(
			{ :tag_name => 'a', :class => /foo/ },
			{ :tag_name => 'div', :id => 'bar' }
	)
end

Then(/^within (\d+) seconds I get an error waiting for "(.*?)"( disappear)?$/) do |timeout, text, condition|
	if condition
		condition = :while
	else
		condition = :until
	end

	begin
		ll.browser.wait(
			:timeout => timeout,
			:text => text,
			:condition => condition,
			:screenshot => true,
			:groups => ["wait"]
		)
		ll.error(
			:message => "Didn't receive an error with this timeout",
			:screenshot => false,
			:groups => ["wait"]
		)
	rescue RuntimeError => err
	end
end

Then(/^a screenshot should have been created$/) do
	# Check if there is a screenshot with the correct name
  folder = ll.config("screenshot_dir","screenshots")
	screenshot_prefix = ll.scenario.time[:timestamp] + "_" + ll.scenario.id
	if not Dir["#{folder}/#{screenshot_prefix}*"]
		ll.error(
			:message => "Didn't find a screenshot for this scenario",
			:groups => ["screenshot"]
		)
	end
end

Then(/^I expect javascript errors$/) do
	if ll.browser.get_js_errors.length > 0
		ll.scenario.check_browser_errors = false
	else
		ll.error(
			:message => "No Javascript errors detected",
			:groups => ["error"]
		)
	end
end

Then(/^I expect a (\d+) status code$/) do |expected|
	expected = expected.to_i
	if ll.browser.get_http_status == expected && expected > 299
		ll.scenario.check_browser_errors = false
	elsif ll.browser.get_http_status != expected
		ll.error(
			:message => "Incorrect status code: #{ll.browser.get_http_status}",
			:groups => ["error"]
		)
	end
end

Then(/^I expect (no|\d+) HTML errors?$/) do |expected|
	expected = expected.to_i
	ll.scenario.check_browser_errors = false
	if ll.browser.get_html_errors.length != expected
		ll.error(
			:message => "Expected #{expected} errors: #{ll.browser.get_html_errors}",
			:groups => ["error"]
		)
	end
end

Then(/^the firefox browser named "(.*?)" has a profile$/) do |name|
	if ll.scenario.storage.has? name
		browser = ll.scenario.storage.get name
		if browser.driver.capabilities.firefox_profile.nil?
			raise "Profile is not set"
		end
	else
		ll.error("No item in the storage named #{name}")
	end
end

Then(/^I expect the "(.*?)" to exist$/) do |name|
	ll.browser.find(name)
end

Then(/^I expect an? (.*?) element to exist$/) do |element|
	ll.browser.find(element.to_sym)
end

Then(/^I expect to find an? (.*?) element with (.*?) "(.*?)"$/) do |element, attribute, text|
	settings = [
		{element.downcase => { attribute.to_sym => /#{text}/}},
		{:like =>{
			:element => element.downcase,
			:attribute => attribute,
			:include => text
			}},
		{:like => [element.downcase, attribute, text]}
	]
	settings.each do |setting|
		# Find always throws an error if not found
		elem_find = ll.browser.find(setting)
		elem_findall = ll.browser.findAll(setting).first
		if elem_find != elem_findall
			ll.error "Incorrect results"
		end
	end
end

Then(/^I expect to find an? (.*?) element or an? (.*?) element$/) do |element1, element2|
	element = ll.browser.find([element1.to_sym, element2.to_sym])
end

Then(/^I should (not )?find "(.*?)" ([0-9]+ times )?using "(.*?)" as context$/) do |result, number, id, name|
	context = ll.scenario.storage.get name
	if context.nil?
		ll.error(:not_found => "Find context in storage")
	end
	begin
		settings = {:element => id, :context => context}
		if number == "a"
			element = ll.browser.find(settings)
		else
			elements = ll.browser.findAllPresent(settings)
			if elements.length != number.to_i
				ll.error("Incorrect number of elements: #{elements.length}")
			end
		end
	rescue
		if result.nil?
			raise $!
		end
	end
end
