#!/usr/bin/ruby

class Chords
  attr_accessor :chords

  @@chords = {
      :A  => %w(     A2  E3  A3  C#3 E4  ),
      :B  => %w(     B2  F#3 B3  D#3 F#4 ),
      :C  => %w(     C3  E3  G3  C4  E4  ),
      :D  => %w(         D3  A3  D4  F#4 ),
      :E  => %w( E2  B2  E3  G#3 B3  E4  ),
      :F  => %w( F2  C3  F3  A3  C4  F4  ),
      :G  => %w( G2  B2  D3  G3  B3  G4  ),

      :Am => %w(     A2  E3  A3  C3  E4  ),
      :Bm => %w(     B2  F#3 B3  D3  F#4 ),
      :Cm => %w(     C3  G3  C4  D#3 G4  ),
      :Dm => %w(         D3  A3  D4  F4  ),
      :Em => %w( E2  B2  E3  G3  B3  E4  ),
      :Fm => %w( F2  C3  F3  G#3 C4  F4  ),
      :Gm => %w( G2  D3  G3  A#3 D4  G4  ),
    }

  def self.method_missing(m, *args, &block)
    return @@chords[m] if @@chords.keys.include? m
    super
  end

  def self.all_chords
    @@chords
  end

end

class EarPractice
  attr_accessor :training_set

  def initialize(*chords)
    set = chords
    set = chords.shift if chords.size == 1
    raise "You must pass an array of notes to practice" unless set.is_a? Array
    self.training_set = set
  end

  def play(chord, interval = 0.05)
    raise "`which` command not found" unless `which`.empty?
    raise "`play` command not found" if `which play`.empty?
    notes = Chords.send(chord)
    intervals = notes.size.times.map { |i| interval * i }
    `play -q -n synth pl #{notes.join " pl "} delay #{intervals.join " "} remix - fade 0 4 .1 norm -1`
  end

  def run(num_times = 10)
    score = 0
    play_thread = nil
    begin
      num_times.times do
        chord = training_set.sample
        play_thread = fork { 4.times { play chord } }
        print "Enter chord name: "
        guessed_chord = gets.chomp
        score += 1 if guessed_chord == chord
        Process.kill "TERM", play_thread
        play_thread = nil
        sleep 2
      end
    rescue SignalException
      Process.kill "TERM", play_thread if play_thread
    end
    puts
    puts "You scored ** #{score}/#{num_times} **"
  end

end

if $0 == __FILE__
  puts "What chords do you want to practice?"
  chord_string = gets.chomp
  chords = chord_string.scan /[A-G]m?/

  puts "How many times?"
  num_times = gets.to_i

  e = EarPractice.new chords
  puts "Listen to the chords and fill in with the correct answer."
  puts "When you are ready press ENTER..."
  puts
  gets

  e.run num_times
end

