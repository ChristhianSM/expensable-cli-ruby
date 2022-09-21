require "httparty"
require "json"

module Services
  class Sessions
    include HTTParty

    base_uri "https://expensable-api.herokuapp.com/"

    def self.login(credentials)
      options = {
        headers: { "Content-Type": "application/json" },
        body: credentials.to_json
      }
      loading
      response = post("/login", options)
      raise HTTParty::ResponseError, response unless response.success?

      JSON.parse(response.body, symbolize_names: true)
    end

    def self.logout(token)
      options = {
        headers: {
          Authorization: "Token token=#{token}",
          "Content-Type": "application/json"
        }
      }
      response = delete("/logout", options)

      raise HTTParty::ResponseError, response unless response.success?
    end

    def self.loading
      (1..15).each do |_caracter|
        sleep(0.1)
        print ".".green
      end
      puts ""
    end
  end
end

# https://expensable-api.herokuapp.com/
