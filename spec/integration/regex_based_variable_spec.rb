# frozen_string_literal: true

require "spec_helper"
require "uri"

# module IntegrationTest
#   class SampleTemplate < EzTemplate::Base
#     variable %r{\Ahttps://.*\Z} do |match_data, path|
#       uri = URI.parse(match_data[0])
#       "#{uri.scheme}://#{uri.host}/#{path}"
#     end
#   end
# end
#
# module EzTemplate
#   RSpec.describe EzTemplate do
#     describe ".render" do
#       let :template do
#         ::IntegrationTest::SampleTemplate.new
#       end
#
#       let :base_template do
#         <<~TEMPLATE
#           Click this link to get a discount!!
#           URL: {{https://example.com/foobar/hoge/huga/}}
#         TEMPLATE
#       end
#
#       it "renders template with predefined variables" do
#         template.parse(base_template)
#
#         result = template.render(path: "index.html")
#
#         expect(result).to eq(<<~EXPECT)
#           Click this link to get a discount!!
#           URL: https://example.com/index.html
#         EXPECT
#       end
#     end
#   end
# end
