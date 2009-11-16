# -*- coding: utf-8 -*-

require 'kramdown/parser'
require 'kramdown/converter'
require 'kramdown/extension'

module Kramdown

  # The kramdown version.
  VERSION = '0.1.0'

  # The main interface to kramdown.
  #
  # This class provides a one-stop-shop for using kramdown to convert text into various output
  # formats. Use it like this:
  #
  #   require 'kramdown'
  #   doc = Kramdown::Document.new('This *is* some kramdown text')
  #   puts doc.to_html
  #
  # The #to_html method is a shortcut for using the Converter::ToHtml class. If other converters are
  # added later, there may be additional shortcut methods.
  #
  # The second argument to the #new method is an options hash for customizing the behaviour of
  # kramdown.
  class Document

    # Currently available options are:
    #
    # [:auto_ids (used by the parser)]
    #    A boolean value deciding whether automatic header ID generation is used. Default: +false+.
    # [:filter_html (used by the HTML converter)]
    #    An array of HTML tag names that defines which tags should be filtered from the output. For
    #    example, if the value contains +iframe+, then all HTML +iframe+ tags are filtered out and
    #    only the body is displayed. Default: empty array.
    # [:footnote_nr (used by the HTML converter)]
    #    The initial number used for creating the link to the first footnote. Default: +1+.
    DEFAULT_OPTIONS={
      :footnote_nr => 1,
      :filter_html => [],
      :auto_ids => false
    }


    # The element tree of the document. It is immediately available after the #new method has been
    # called.
    attr_accessor :tree

    # The options hash which holds the options for parsing/converting the Kramdown document. It is
    # possible that these values get changed during the parsing phase.
    attr_accessor :options

    # An array of warning messages. It is filled with warnings during the parsing phase (i.e. in
    # #new).
    attr_reader :warnings

    # Holds needed parse information like ALDs, link definitions and so on.
    attr_reader :parse_infos

    # Holds an instance of the extension class.
    attr_reader :extension


    # Create a new Kramdown document from the string +source+ and use the provided +options+ (see
    # DEFAULT_OPTIONS for a list of available options). The +source+ is immediately parsed by the
    # kramdown parser sothat after this call the output can be generated.
    #
    # The parameter +ext+ can be used to set a custom extension class. Note that the default
    # kramdown extension should be available in the custom extension class.
    def initialize(source, options = {}, ext = nil)
      @options = DEFAULT_OPTIONS.merge(options)
      @warnings = []
      @parse_infos = {}
      @extension = extension || Kramdown::Extension.new(self)
      @tree = Parser::Kramdown.parse(source, self)
    end

    # Convert the document to HTML. Uses the Converter::ToHtml class for doing the conversion.
    def to_html
      Converter::Html.convert(@tree, self)
    end

  end


  # Represents all elements in the parse tree.
  #
  # kramdown only uses this one class for representing all available elements in a parse tree
  # (paragraphs, headers, emphasis, ...). The type of element can be set via the #type accessor.
  class Element

    # A symbol representing the element type. For example, +:p+ or +:blockquote+.
    attr_accessor :type

    # The value of the element. The interpretation of this field depends on the type of the element.
    # Many elements don't use this field.
    attr_accessor :value

    # The options hash for the element. It is used for storing arbitray options as well as the
    # *attributes* of the element under the <tt>:attr</tt> key.
    attr_accessor :options

    # The child elements of this element.
    attr_accessor :children


    # Create a new Element object of type +type+. The optional parameters +value+ and +options+ can
    # also be set in this constructor for convenience.
    def initialize(type, value = nil, options = {})
      @type, @value, @options = type, value, options
      @children = []
    end

  end

end

