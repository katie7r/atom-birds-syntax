settings =
  config:
    scheme:
      type: 'string'
      default: 'Pigeon'
      enum: [
        # # "Bluejay"
        # # "Cardinal"
        # "Chickadee"
        # # "Crow"
        # # "Flamingo"
        # "Gouldian Finch"
        "House Finch"
        "Kingfisher"
        "Kookaburra"
        "Magpie"
        # "Orchard Oriole"
        # "Peafowl"
        "Pigeon"
        # # "Rooster"
        "Toucan"
      ]
    style:
      type: 'string'
      default: 'Dark'
      enum: ["Dark", "Light"]
    matchUserInterfaceTheme:
      type: 'boolean'
      default: true
      description: "When enabled the style will be matched to the current UI theme by default."

module.exports = settings
