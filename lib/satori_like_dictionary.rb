require 'nano_template'
require 'ostruct'

# Satori like dictionary for Ukagaka SHIORI subsystem
class SatoriLikeDictionary
  attr_reader :dictionary

  # initialize SatoriLikeDictionary
  # @param [Events] events events definition (if nil then use the dictionary itself)
  def initialize(events=nil)
    @dictionary = OpenStruct.new
    @events = events || @dictionary
  end

  # load all files in a directory as satori like dictionaries
  # @param [String] directory path to dictionary
  # @param [String] ext file extension filter
  def load_all(directory, ext = 'txt')
    files = Dir[File.join(directory, "*.#{ext}")]
    files.each {|file| parse(File.read(file))}
  end

  # load a file as satori like dictionary
  # @param [String] file path to file
  def load(file)
    parse(File.read(file))
  end

  # parse and register satori like dictionary source
  # @param [String] source satori like dictionary source
  def parse(source)
    scope = :comment
    current_entry = nil
    entry_name = nil
    source.each_line do |line|
      line = line.chomp
      if line.start_with?("＃")
        # skip comment line (incompatible with satori original)
      elsif line.start_with?("＊")
        scope = :entry
        entry_name = linebody(line).strip
        current_entry = Entry.new
        @dictionary[entry_name] ||= Entries.new
        @dictionary[entry_name] << current_entry
      elsif line.start_with?("＠")
        scope = :word_entry
        entry_name = linebody(line).strip
      else
        if scope == :entry
          if line.start_with?("＄") # incompatible with satori original (＄ruby code (same as %)
            current_entry << Code.new(linebody(line))
          elsif line.start_with?("：")
            current_entry << ChangeScopeLine.new(linebody(line))
          elsif line.start_with?("＞")
            current_entry << Jump.new(linebody(line))
          elsif line.start_with?("→") # incompatible with satori original (→キャラ名
            current_entry << Call.new(linebody(line))
          elsif line.start_with?("≫")
            $stderr.puts "警告: ≫は実装されていません。スキップします。"
          else
            current_entry << Line.new(line)
          end
        elsif scope == :word_entry
          if line.start_with?("＄", "＞", "≫", "→")
            $stderr.puts "警告: ＠の中で行頭#{line[0]}が使われています。文字列として解釈されます。"
          end
          unless line.strip.empty? # skip empty line
            @dictionary[entry_name] ||= Entries.new
            @dictionary[entry_name] << Word.new(line)
          end
        end
        # skip :comment scope
      end
    end
  end

  # call a named entry
  # @param [String] entry_name entry name
  # @param [OpenStruct] request request hash
  # @return [String|OpenStruct] result
  def talk(entry_name, request)
    if entries = @dictionary[entry_name]
      entries.render(@events, request)
    else
      nil
    end
  end

  # call the "ai talk" entry
  # @param [OpenStruct] request request hash
  # @return [String|OpenStruct] result
  def aitalk(request)
    talk("", request)
  end

  # satori token renderer
  module Renderer
    # number map
    NUMBERS = {"０" => 0, "１" => 1, "２" => 2, "３" => 3, "４" => 4, "５" => 5, "６" => 6, "７" => 7, "８" => 8, "９" => 9}

    # execute template
    # @param [Events] events events definition
    # @param [OpenStruct] request request hash
    # @return [String] result
    def render_template(events, request)
      template = NanoTemplate.new.template(to_template)
      context = TemplateContext.new(events, request)
      template.call(context)
    end

    # process basic replacements
    # @param [Events] events events definition
    # @param [OpenStruct] request request hash
    # @return [String] result
    def render_base(events, request)
      value = render_template(events, request)
        .gsub(/\b＿(\S+)/, "\\q[\\1,\\1]")
        .gsub(/（([^）]*)）/) do
          content = $1
          if content.match(/^[0-9０-９]+$/)
            "\\s[#{content.gsub(/[０-９]/) {|m| NUMBERS[m]} }]"
          else
            begin
              entry = events.send(content, request) # event
            rescue ArgumentError
              entry = events.send(content) # satori dictionary
            rescue NoMethodError
              entry = nil # wrong event
            end
            if entry.respond_to?(:render) # satori entry
              entry.render(events, request)
            elsif entry.respond_to?(:Value) # ostruct value
              entry.Value
            else # simple value
              entry
            end
          end
        end
        .gsub(/\r?\n/, "\\n")
      value
    end

    # render the content
    # @param [Events] events events definition
    # @param [OpenStruct] request request hash
    # @return [String|OpenStruct] result
    def render(events, request)
      value = render_base(events, request)
      if request.__satori_target_character
        OpenStruct.new({Value: value, Reference0: request.__satori_target_character})
      else
        value
      end
    end
  end

  # line (normal line in entries)
  class Line < String
    # to template
    # @return [String] template
    def to_template
      self + "\n"
    end
  end

  # line with change scope (：)
  class ChangeScopeLine < String
    # to template
    # @return [String] template
    def to_template
      "<%= change_scope %>" + self + "\n"
    end
  end

  # code (＄)
  class Code < String
    # to template
    # @return [String] template
    def to_template
      "<% #{self} %>"
    end
  end

  # jump (＞)
  class Jump < String
    # to template
    # @return [String] template
    def to_template
      "<%= jump_to('#{self.gsub(/'/) {"\\'"}}') %>"
    end
  end

  # communication call (→)
  class Call < String
    # to template
    # @return [String] template
    def to_template
      "<% call_to('#{self.gsub(/'/) {"\\'"}}') %>"
    end
  end

  # word (＠)
  class Word < String
    include Renderer
    alias_method :to_template, :to_s
  end

  # entry (＊)
  class Entry < Array
    include Renderer

    # @param [Events] events events definition
    # @param [OpenStruct] request request hash
    def render_base(events, request)
      '\1' + super
    end

    # to template
    # @return [String] template
    def to_template
      still_empty = true
      reverse.reject do |element| # remove last empty lines
        still_empty = still_empty && element.is_a?(Line) && element.empty?
      end.map do |element|
        element.to_template
      end.reverse.join('').chomp
    end
  end

  # random select entries
  class Entries < Array
    # render the content
    # @param [Events] events events definition
    # @param [OpenStruct] request request hash
    def render(events, request)
      shuffle.first.render(events, request)
    end
  end

  # template runtime context class
  class TemplateContext < OpenStruct
    attr_reader :events, :request

    # initialize context
    # @param [Events] events events definition
    # @param [OpenStruct] request request hash
    def initialize(events, request)
      @events = events
      @request = request
    end

    # change character scope
    def change_scope
      request.__satori_scope = request.__satori_scope.nil? || request.__satori_scope == 1 ? 0 : 1
      '\\' + request.__satori_scope.to_s
    end

    # jump to entry
    # @param [String] target_entry jump target entry name
    def jump_to(target_entry)
      "（#{target_entry}）\\e"
    end

    # set communication target
    # @param [String] target_character communication target character name
    def call_to(target_character)
      request.__satori_target_character = target_character
    end

    # method_missing
    def method_missing(method_name, *args)
      if result = method_name.match(/^r(\d+)$/) # r0 -> request.Reference0
        request["Reference#{result[1]}"]
      else
        super
      end
    end
  end

  private

  # line[1...line.size]
  # @param [String] line line
  # @return [String] line
  def linebody(line)
    line[1...line.size]
  end
end

# satori like template integrated events base class
class SatoriLikeDictionaryIntegratedEvents

  # initialize events
  def initialize
    @satori_like_dictionary = SatoriLikeDictionary.new(self)
  end

  # "＿" compatible OnChoiceSelect
  # @param [OpenStruct] request request hash
  # @return [String|OpenStruct] result
  def OnChoiceSelect(request)
    public_send(request.Reference0, request)
  end

  private

  # load all files in a directory as satori like dictionaries
  # @param [String] file path to file
  def load_file(file)
    @satori_like_dictionary.load(file)
  end

  # load a file as satori like dictionary
  # @param [String] directory path to dictionary
  # @param [String] ext file extension filter
  def load_all_dictionary(directory, ext = 'txt')
    @satori_like_dictionary.load_all(directory, ext)
  end

  # call a named entry
  # @param [OpenStruct] request request hash
  # @param [String] method from method name
  # @return [String|OpenStruct] result
  def talk(request, method = nil)
    unless method
      # detect caller method name (= request ID)
      if RUBY_ENGINE == 'opal'
        matched = caller[1].match(/\[as \$(.*?)\]/)
        return unless matched
        method = matched[1]
      else
        method = caller_locations.first.label
      end
    end
    @satori_like_dictionary.talk(method, request)
  end

  # call a "ai talk" entry
  # @param [OpenStruct] request request hash
  # @return [String|OpenStruct] result
  def aitalk(request)
    @satori_like_dictionary.aitalk(request)
  end

end
