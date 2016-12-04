require 'httparty'

class Macbeth
  include HTTParty

  base_uri 'http://www.ibiblio.org/xml/examples/shakespeare'

  attr_accessor :speakers

  def initialize
    @speakers = []
  end

  def analyze
    parse_data(do_request.parsed_response)
  end

  def do_request
    self.class.get('/macbeth.xml')
  end

  def parse_data(data)
    data['PLAY']['ACT'].each do |act|
      act['SCENE'].each { |scene| parse_scene(scene) }
    end
  end

  def parse_scene(scene)
    scene['SPEECH'].each { |speech| parse_speech(speech) }
  end

  def parse_speech(speech)
    return if speech['SPEAKER'] == 'ALL'

    if speech['SPEAKER'].is_a?(Array)
      speech['SPEAKER'].each { |name| parse_speaker(name, speech['LINE']) }
    else
      parse_speaker(speech['SPEAKER'], speech['LINE'])
    end
  end

  def parse_speaker(name, lines)
    count_lines(find_or_create_speaker(name), lines)
  end

  def results
    sorted_speakers.map { |speaker| formatted_speaker(speaker) }
  end

  def formatted_speaker(speaker)
    "#{speaker[:lines_count]} #{speaker[:name].capitalize}"
  end

  def sorted_speakers
    speakers.sort_by { |speaker| -speaker[:lines_count] }
  end

  def find_speaker(name)
    speakers.find { |speaker| speaker[:name] == name }
  end

  def create_speaker(name)
    speaker = { name: name, lines_count: 0 }
    speakers.push(speaker)
    speaker
  end

  def find_or_create_speaker(name)
    find_speaker(name) || create_speaker(name)
  end

  def count_lines(speaker, lines)
    if lines.is_a?(Array)
      speaker[:lines_count] += lines.count
    else
      speaker[:lines_count] += 1
    end
  end
end
