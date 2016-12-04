require File.expand_path('../test_helper', __FILE__)
require File.expand_path('../../lib/macbeth', __FILE__)

class MacbethTest < Minitest::Test
  def setup
    @macbeth = Macbeth.new
  end

  def test_that_speakers_is_set
    assert_equal [], @macbeth.speakers
  end

  def test_analyze
    raw_response_file = File.new('./tests/support/macbeth.xml')
    stub_request(:get, 'http://www.ibiblio.org/xml/examples/shakespeare/macbeth.xml')
      .to_return(status: 200, headers: { content_type: 'text/xml' }, body: raw_response_file)
    Spy.on(@macbeth, :parse_data)
    @macbeth.analyze
    assert_received @macbeth, :parse_data
  end

  def test_parse_data
    data = {
      'PLAY' => {
        'ACT' => [
          "TITLE"=>"ACT I",
          "SCENE"=>[
            {
              "TITLE"=>"SCENE I.  A desert place.",
              "STAGEDIR"=>["Thunder and lightning. Enter three Witches", "Exeunt"],
              "SPEECH"=>[{"SPEAKER"=>"First Witch", "LINE"=>["When shall we three meet again", "In thunder, lightning, or in rain?"]}]
            }
          ]
        ]
      }
    }
    Spy.on(@macbeth, :parse_scene)
    @macbeth.parse_data(data)
    assert_received @macbeth, :parse_scene
  end

  def test_parse_scene
    scene = {
      'TITLE'=>'SCENE I.  A desert place.',
      'STAGEDIR'=>['Thunder and lightning. Enter three Witches', 'Exeunt'],
      'SPEECH'=>[{'SPEAKER'=>'First Witch', 'LINE'=>['When shall we three meet again', 'In thunder, lightning, or in rain?']}]
    }
    Spy.on(@macbeth, :parse_speech)
    @macbeth.parse_scene(scene)
    assert_received @macbeth, :parse_speech
  end

  def test_parse_speech_all
    speech = {'SPEAKER'=>'First Witch', 'LINE'=>['When shall we three meet again', 'In thunder, lightning, or in rain?']}
    Spy.on(@macbeth, :parse_speaker)
    @macbeth.parse_speech(speech)
    assert_received @macbeth, parse_speaker
  end

  def test_parse_speech_all
    speech = {'SPEAKER'=>'ALL', 'LINE'=>['When shall we three meet again', 'In thunder, lightning, or in rain?']}
    parse_speaker_spy = Spy.on(@macbeth, :parse_speaker)
    @macbeth.parse_speech(speech)
    assert_equal 0, parse_speaker_spy.calls.count
  end

  def test_parse_speech_array
    speech = {'SPEAKER'=>['MACBETH', 'LENNOX'], 'LINE'=>['When shall we three meet again', 'In thunder, lightning, or in rain?']}
    parse_speaker_spy = Spy.on(@macbeth, :parse_speaker)
    @macbeth.parse_speech(speech)
    assert_equal 2, parse_speaker_spy.calls.count
  end

  def test_parse_speaker
    name = 'First Witch'
    lines = ['When shall we three meet again', 'In thunder, lightning, or in rain?']
    Spy.on(@macbeth, :count_lines)
    Spy.on(@macbeth, :find_or_create_speaker)
    @macbeth.parse_speaker(name, lines)
    assert_received @macbeth, :count_lines
    assert_received @macbeth, :find_or_create_speaker
  end

  def test_formatted_speaker
    speaker = { name: 'MACBETH', lines_count: 5 }
    result = '5 Macbeth'
    assert_equal result, @macbeth.formatted_speaker(speaker)
  end

  def test_sorted_speakers
    @macbeth.speakers = [{ name: 'First Witch', lines_count: 2 }, { name: 'Macbeth', lines_count: 5 }]
    result = [{ name: 'Macbeth', lines_count: 5 }, { name: 'First Witch', lines_count: 2 }]
    assert_equal result, @macbeth.sorted_speakers
  end

  def test_find_speakers_returns_speaker
    speaker = { name: 'Macbeth', lines_count: 5 }
    @macbeth.speakers << speaker
    assert_equal speaker, @macbeth.find_speaker('Macbeth')
  end

  def test_find_speakers_returns_nil
    speaker = { name: 'Macbeth', lines_count: 5 }
    assert_nil @macbeth.find_speaker('Macbeth')
  end

  def test_create_speaker
    name = 'Macbeth'
    result = { name: 'Macbeth', lines_count: 0 }
    assert_equal result, @macbeth.create_speaker(name)
    assert_includes @macbeth.speakers, result
  end

  def test_count_lines_with_array
    speaker = { name: 'First Witch', lines_count: 2 }
    lines = ['When shall we three meet again', 'In thunder, lightning, or in rain?']
    assert_equal 4, @macbeth.count_lines(speaker, lines)
  end

  def test_count_lines_with_string
    speaker = { name: 'First Witch', lines_count: 2 }
    lines = 'When shall we three meet again'
    assert_equal 3, @macbeth.count_lines(speaker, lines)
  end
end
