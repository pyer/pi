require "http"
require "html"
require "uri"
require "mime"

# A handler that lists directories and serves files under a given public directory.
#
# This handler can send precompressed content, if the client accepts it, and a file
# with the same name and `.gz` extension appended is found in the same directory.
# Precompressed files are only served if they are newer than the original file.
#
class PI::StaticFileHandler
  include HTTP::Handler

  # In some file systems, using `gz --keep` to compress the file will keep the
  # modification time of the original file but truncating some decimals. We
  # serve the gzipped file nonetheless if the .gz file is modified by a duration
  # of `TIME_DRIFT` before the original file. This value should match the
  # granularity of the underlying file system's modification times
  private TIME_DRIFT = 10.milliseconds

  @public_dir : Path

  # Creates a handler that will serve files in the given *public_dir*, after
  # expanding it (using `File#expand_path`).
  #
  def initialize(public_dir : String, @log = Log.for("http.server"))
    @public_dir = Path.new(public_dir).expand
    @log.info {"public directory = #{@public_dir}"}
  end

  def call(context : HTTP::Server::Context) : Nil
    @log.info {"call static file handler"}

    if context.request.method.in?("GET", "HEAD")
      request_path = URI.decode(context.request.path.not_nil!)
      # File path cannot contain '\0' (NUL) because all filesystem I know
      # don't accept '\0' character as file name.
      # ".." is not allowed for security
      if request_path.includes?('\0')|| request_path.includes?("..")
        context.response.respond_with_status(:bad_request)
        return
      end

      file_path = @public_dir.join(request_path)
      file_info = File.info?(file_path)

      return call_next(context) unless file_info
      return serve_file_with_cache(context, file_info, file_path) if file_info.file?
    end
    # Not a normal file (directory/FIFO/device/socket)
    # or not a GET or HEAD method
    call_next(context)
  end

  private def serve_file_with_cache(context : HTTP::Server::Context, file_info, file_path : Path)
    last_modified = file_info.modification_time
    add_cache_headers(context.response.headers, last_modified)

    if cache_request?(context, last_modified)
      context.response.status = :not_modified
      return
    end

    # Checks if pre-gzipped file can be served
    original_file_path = file_path
    if context.request.headers.includes_word?("Accept-Encoding", "gzip")
      gz_file_path = Path["#{file_path}.gz"]

      if (gz_file_info = File.info?(gz_file_path)) &&
         last_modified - gz_file_info.modification_time < TIME_DRIFT
        file_path = gz_file_path
        file_info = gz_file_info
        context.response.headers["Content-Encoding"] = "gzip"
      end
    end

    serve_file(context, file_info, file_path, original_file_path, last_modified)
  end

  private def serve_file(context : HTTP::Server::Context, file_info, file_path : Path, original_file_path : Path, last_modified : Time)
    context.response.content_type = MIME.from_filename(original_file_path.to_s, "application/octet-stream")

    begin
      File.open(file_path) do |file|
        if range_header = context.request.headers["Range"]?
          serve_file_range(context, file, range_header, file_info)
        else
          context.response.headers["Accept-Ranges"] = "bytes"

          serve_file_full(context, file, file_info)
        end
      end
    rescue File::Error
      # If there's any file error, we report the file as not existing.
      # Even if it exists but is not readable, we don't want to disclose its
      # existence.
      context.response.respond_with_status(:not_found)
      return
    end
  end

  # *file* should be seekable, that's implement #seek method
  private def serve_file_range(context : HTTP::Server::Context, file : IO, range_header : String, file_info)
    range_header = range_header.lchop?("bytes=")
    unless range_header
      context.response.headers["Content-Range"] = "bytes */#{file_info.size}"
      context.response.status = :range_not_satisfiable
      context.response.close
      return
    end

    ranges = parse_ranges(range_header, file_info.size)
    unless ranges
      context.response.respond_with_status :bad_request
      return
    end

    if file_info.size.zero? && ranges.size == 1 && ranges[0].begin.zero?
      context.response.status = :ok
      return
    end

    # If any of the ranges start beyond the end of the file, we return an
    # HTTP 416 Range Not Satisfiable.
    # See https://www.rfc-editor.org/rfc/rfc9110.html#section-14.1.2-11.1
    if ranges.any? { |range| range.begin >= file_info.size }
      context.response.headers["Content-Range"] = "bytes */#{file_info.size}"
      context.response.status = :range_not_satisfiable
      context.response.close
      return
    end

    ranges.map! { |range| range.begin..(Math.min(range.end, file_info.size - 1)) }

    context.response.status = :partial_content

    if ranges.size == 1
      range = ranges.first
      file.seek range.begin
      context.response.headers["Content-Range"] = "bytes #{range.begin}-#{range.end}/#{file_info.size}"
      IO.copy file, context.response, range.size
    else
      MIME::Multipart.build(context.response) do |builder|
        content_type = context.response.headers["Content-Type"]?
        context.response.headers["Content-Type"] = builder.content_type("byterange")

        ranges.each do |range|
          file.seek range.begin
          headers = HTTP::Headers{
            "Content-Range"  => "bytes #{range.begin}-#{range.end}/#{file_info.size}",
            "Content-Length" => range.size.to_s,
          }
          headers["Content-Type"] = content_type if content_type
          chunk_io = IO::Sized.new(file, range.size)
          builder.body_part headers, chunk_io
        end
      end
    end
  end

  private def serve_file_full(context : HTTP::Server::Context, file : IO, file_info)
    context.response.status = :ok
    context.response.content_length = file_info.size
    IO.copy(file, context.response)
  end

  # TODO: Optimize without lots of intermediary strings
  private def parse_ranges(header, file_size)
    ranges = [] of Range(Int64, Int64)
    header.split(",") do |range|
      start_string, dash, finish_string = range.lchop(' ').partition("-")
      return if dash.empty?
      start = start_string.to_i64?
      return if start.nil? && !start_string.empty?
      if finish_string.empty?
        return if start_string.empty?
        finish = file_size
      else
        finish = finish_string.to_i64? || return
      end
      if file_size.zero?
        # > When a selected representation has zero length, the only satisfiable
        # > form of range-spec in a GET request is a suffix-range with a non-zero suffix-length.

        if start
          # This return value signals an unsatisfiable range.
          return [1_i64..0_i64]
        elsif finish <= 0
          return
        else
          start = finish = 0_i64
        end
      elsif !start
        # suffix-range
        start = {file_size - finish, 0_i64}.max
        finish = file_size - 1
      end

      range = (start..finish)
      return unless 0 <= range.begin <= range.end
      ranges << range
    end
    ranges unless ranges.empty?
  end

  private def add_cache_headers(response_headers : HTTP::Headers, last_modified : Time) : Nil
    response_headers["Etag"] = %{W/"#{last_modified.to_unix}"}
    response_headers["Last-Modified"] = HTTP.format_time(last_modified)
  end

  private def cache_request?(context : HTTP::Server::Context, last_modified : Time) : Bool
    # According to RFC 7232:
    # A recipient must ignore If-Modified-Since if the request contains an If-None-Match header field
    if if_none_match = context.request.if_none_match
      match = {"*", context.response.headers["Etag"]}
      if_none_match.any? { |etag| match.includes?(etag) }
    elsif if_modified_since = context.request.headers["If-Modified-Since"]?
      header_time = HTTP.parse_time(if_modified_since)
      # File mtime probably has a higher resolution than the header value.
      # An exact comparison might be slightly off, so we add 1s padding.
      # Static files should generally not be modified in subsecond intervals, so this is perfectly safe.
      # This might be replaced by a more sophisticated time comparison when it becomes available.
      !!(header_time && last_modified <= header_time + 1.second)
    else
      false
    end
  end

end
