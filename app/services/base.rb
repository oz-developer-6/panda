# frozen_string_literal: true

module Services
  class Base
    Result = Struct.new(:success?, :data, :errors, :status, keyword_init: true) do
      def failure?
        !success?
      end
    end

    def self.call(*args, **kwargs, &block)
      new(*args, **kwargs, &block).call
    end

    private

    def success(data = nil, status: 200)
      Result.new(success?: true, data: data, errors: [], status: status)
    end

    def failure(errors, status: 422)
      errors = [errors] unless errors.is_a?(Array)
      Result.new(success?: false, data: nil, errors: errors, status: status)
    end

    def format_model_errors(model)
      model.errors.map { |field, msgs| msgs.map { |msg| "#{field} #{msg}" } }.flatten
    end
  end
end
