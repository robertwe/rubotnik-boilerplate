require 'json'

# Also known as 'generic template'
# https://developers.facebook.com/docs/messenger-platform/send-api-reference/generic-template

# TODO:Examples for all basic UI elements and content types

module UIElements

  # NOTE: default_action not supported in alpha
  class FBCarousel
    def initialize(elements)
      @template = {
        # TODO: Do we need to provide an id at init?
        recipient: { id: nil},
        message: {
          attachment: {
            type: 'template',
            payload: {
              template_type: 'generic',
              image_aspect_ratio: 'horizontal',
              elements: parse_elements(elements)
            }
          }
        }
      }
    end

    # TODO: Do we need two separate methods for build and send?
    def send(id)
      template = build(id)
      Bot.deliver(template, access_token: ENV['ACCESS_TOKEN'])
    end

    def build(id)
      @template[:recipient][:id] = id
      @template
    end

    # set image aspect ratio to 'square'
    def square_images
      @template[:message][:attachment][:payload][:image_aspect_ratio] = "square"
      self
    end

    # set image aspect ratio to 'square'
    def horizontal_images
      @template[:message][:attachment][:payload][:image_aspect_ratio] = "horizontal"
      self
    end

    private

    # [{title: String, image_url: String, subtitle: String, default_url: String, buttons: []}]
    def parse_elements(elements)
      elements = [elements] if elements.class == Hash
      elements.map do |elt|
        # TODO: custom error?
        raise ArgumentError, "Title is a required field" unless elt.key?(:title)
        elt[:buttons] = parse_buttons(elt[:buttons])
        elt
      end
    end

    # TODO: Extract button functionality to Button class?
    # Account for all button types from API or remove type check altogether!

    # [{type: :web_url, url: String, title: String}]
    # [{type: :postback, title: String, payload: String}]
    def parse_buttons(buttons)
      return [] if buttons.nil? || buttons.empty?
      buttons.map do |button|
        button[:type] = button[:type].to_s
        button
      end
    end
  end
end
