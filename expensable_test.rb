require "minitest/autorun"
require_relative "services/sessions"
class ExpensableTest < Minitest::Test
  def setup
    @session = Services::Sessions
  end

  def test_raises_erros_when_incorrect_credentials_for_login
    assert_raises(HTTParty::ResponseError) do
      @session.login({ email: "rodrigo.lopez.160795@hotmailcom", password: 12_345 })
    end
  end

  def test_raises_error_in_logout_when_incorrect_token_given
    @session.login({ email: "christhian2524@gmail.com", password: "123456" })
    token = "not_a_valid_token"
    assert_raises(HTTParty::ResponseError) { @session.logout(token) }
  end
end
