module ErrorHandlerConcern
  extend ActiveSupport::Concern

  private
  def mid_document_not_found
    redirect_to '/404'
  end

  def e_not_authorized_exception
    redirect_to '/403'
  end

  def ac_invalid_authenticity_token
    redirect_to '/500'
  end
end