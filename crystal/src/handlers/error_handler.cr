# A handler that invokes the next handler and, if that next handler raises
# an exception, returns with a 500 (Internal Server Error) status code.
#
# Otherwise a generic error message is returned to the client.
#
class ErrorHandler
  include HTTP::Handler

  def initialize(@log = Log.for("http.server"))
  end

  def call(context : HTTP::Server::Context) : Nil
    @log.info {"call ErrorHandler"}
    call_next(context)
    @log.info {"exit ErrorHandler"}
  rescue ex : HTTP::Server::ClientError
    @log.info(exception: ex.cause) { ex.message }
  rescue ex : Exception
    @log.error(exception: ex) { "Unhandled exception" }
    unless context.response.closed? || context.response.wrote_headers?
        context.response.reset
        context.response.status = :internal_server_error
        context.response.content_type = "text/plain"
        context.response.print("ERROR: ")
        context.response.puts(ex.inspect_with_backtrace)
#       context.response.respond_with_status(:internal_server_error)
    end
  end
end
