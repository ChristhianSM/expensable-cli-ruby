require "httparty"
require "json"

module Services
  class User
    include HTTParty
    base_uri "https://expensable-api.herokuapp.com/"

    def self.signup(credentials)
      options = {
        headers: { "Content-Type": "application/json" },
        body: credentials.to_json
      }
      loading
      response = post("/signup", options)

      raise HTTParty::ResponseError, response unless response.success?

      JSON.parse(response.body, symbolize_names: true)
    end

    def self.update_user(token, credentials)
      options = {
        headers: {
          Authorization: "Token token=#{token}",
          "Content-Type": "application/json"
        },
        body: credentials.to_json
      }
      loading
      response = patch("/profile", options)

      raise HTTParty::ResponseError, response unless response.success?

      JSON.parse(response.body, symbolize_names: true)
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
