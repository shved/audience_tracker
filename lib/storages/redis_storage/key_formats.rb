class RedisStorage
  module KeyFormats
    def session_key(customer_id, video_id)
      "#{customer_id}:#{video_id}"
    end

    def disassemble_session_key(key)
      # rubocop:disable Lint/UselessAssignment
      customer_id, video_id = key.split(':').map { |el| el.to_i }
      # rubocop:enable Lint/UselessAssignment
    end

    def customer_key(customer_id)
      "customers:#{customer_id}"
    end

    def video_key(video_id)
      "videos:#{video_id}"
    end

    def collection_item(id, timestamp)
      "#{id}:#{timestamp}"
    end

    def items_to_ids(items)
      items.map do |item|
        item.split(':')[0]
      end
    end
  end
end
