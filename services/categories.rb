require "httparty"
require "json"

module Services
  class Category
    include HTTParty
    base_uri "https://expensable-api.herokuapp.com/"

    def self.index_categories(token)
      options = {
        headers: { Authorization: "Token token=#{token}" }
      }
      response = get("/categories", options)

      raise HTTParty::ResponseError, response unless response.success?

      JSON.parse(response.body, symbolize_names: true)
    end

    def self.create_category(token, category_data)
      options = {
        headers: {
          Authorization: "Token token=#{token}",
          "Content-Type": "application/json"
        },
        body: category_data.to_json
      }
      response = post("/categories", options)
      raise HTTParty::ResponseError, response unless response.success?

      JSON.parse(response.body, symbolize_names: true)
    end

    def self.update_category(token, category_data, id)
      options = {
        headers: {
          Authorization: "Token token=#{token}",
          "Content-Type": "application/json"
        },
        body: category_data.to_json
      }
      response = patch("/categories/#{id}", options)
      raise HTTParty::ResponseError, response unless response.success?

      JSON.parse(response.body, symbolize_names: true)
    end

    def self.delete_category(token, id)
      options = {
        headers: {
          Authorization: "Token token=#{token}",
          "Content-Type": "application/json"
        }
      }
      response = delete("/categories/#{id}", options)
      raise HTTParty::ResponseError, response unless response.success?

      JSON.parse(response.body, symbolize_names: true) if response.body
    end
  end
end
