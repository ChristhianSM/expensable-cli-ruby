require "httparty"
require "json"

module Services
  class Transaction
    include HTTParty
    base_uri "https://expensable-api.herokuapp.com/"

    def self.index_transactions(token, id)
      options = {
        headers: { Authorization: "Token token=#{token}" }
      }
      response = get("/categories/#{id}/transactions", options)

      raise HTTParty::ResponseError, response unless response.success?

      JSON.parse(response.body, symbolize_names: true)
    end

    def self.create_transaction(token, transaction_data, id)
      options = {
        headers: {
          Authorization: "Token token=#{token}",
          "Content-Type": "application/json"
        },
        body: transaction_data.to_json
      }
      response = post("/categories/#{id}/transactions", options)
      raise HTTParty::ResponseError, response unless response.success?

      JSON.parse(response.body, symbolize_names: true)
    end

    def self.update_transaction(token, transaction_data, id_category, id_transaction)
      options = {
        headers: {
          Authorization: "Token token=#{token}",
          "Content-Type": "application/json"
        },
        body: transaction_data.to_json
      }
      response = patch("/categories/#{id_category}/transactions/#{id_transaction}", options)
      raise HTTParty::ResponseError, response unless response.success?

      JSON.parse(response.body, symbolize_names: true)
    end

    def self.delete_transaction(token, id_category, id_transaction)
      options = {
        headers: {
          Authorization: "Token token=#{token}",
          "Content-Type": "application/json"
        }
      }
      response = delete("/categories/#{id_category}/transactions/#{id_transaction}", options)
      raise HTTParty::ResponseError, response unless response.success?

      JSON.parse(response.body, symbolize_names: true) if response.body
    end
  end
end
