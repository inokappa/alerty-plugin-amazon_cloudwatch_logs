require 'alerty'
require 'aws-sdk'
require 'dotenv'
require 'json'
Dotenv.load

class Alerty
  class Plugin
    class AmazonCloudwatchLogs
      def initialize(config)
        params = {}
        params[:region] = config.aws_region if config.aws_region
        params[:access_key_id] = config.aws_access_key_id if config.aws_access_key_id
        params[:secret_access_key] = config.aws_secret_access_key if config.aws_secret_access_key
        params[:ssl_verify_peer] = false
        @client = Aws::CloudWatchLogs::Client.new(params)
        @subject = config.subject
        @log_group_name = config.log_group_name
        @log_stream_name = config.log_stream_name
	@state_file = config.state_file
        @num_retries = config.num_retries || 3
      end

      def alert(record)
        message = record[:output]
        subject = expand_placeholder(@subject, record)
	event_message = { "subject" => subject, "message" => message, "hostname" => record[:output], "exitstatus" => record[:exitstatus], "duration" => record[:duration] }
	timestamp = Time.now.instance_eval { self.to_i * 1000 + (usec/1000) }
	next_token = read_token
        retries = 0
        begin
          Alerty.logger.info "#{next_token}"
	  if next_token == ""
            resp = @client.put_log_events({
              log_group_name: @log_group_name,
              log_stream_name: @log_stream_name,
              log_events: [
                {
                  timestamp: timestamp, 
                  message: event_message.to_json,
                },
              ]
            })
	    store_token(resp.next_sequence_token)
            Alerty.logger.info "Sent #{{subject: subject, message: message}} to log_group_name: #{@log_group_name} / log_stream_name: #{@log_stream_name} / next_sequence_token: #{resp.next_sequence_token}"
	  else
            resp = @client.put_log_events({
              log_group_name: @log_group_name,
              log_stream_name: @log_stream_name,
              log_events: [ 
                {
                  timestamp: timestamp, 
                  message: event_message.to_json,
                },
              ],
	      sequence_token: next_token
            })
	    store_token(resp.next_sequence_token)
            Alerty.logger.info "Sent #{{subject: subject, message: message}} to log_group_name: #{@log_group_name} / log_stream_name: #{@log_stream_name} / next_sequence_token: #{resp.next_sequence_token}"
	  end
        rescue => e
          retries += 1
          sleep 1
          if retries <= @num_retries
            retry
          else
            raise e
          end
        end
      end

      private

      def expand_placeholder(str, record)
        str.gsub('${command}', record[:command]).gsub('${hostname}', record[:hostname])
      end
 
      def read_token
        return nil unless File.exist?(@state_file)
        File.read(@state_file).chomp
      end

      def store_token(sequence_token)
        open(@state_file, 'w') do |f|
          f.write sequence_token
        end
      end
 
    end
  end
end
