module LineBot
  module Messages
    class TemplateMessage
      include Linebot::Messages::Concern::Carouselable

      def send
        carousel('alter_text', [bubble])
      end

      def bubble

      end
    end
  end
end