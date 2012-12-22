#!/usr/bin/ruby

class Chords
  attr_accessor :chords

  @@chords = {
      :A  => %w(     A2  E3  A3  C#3 E4  ),
      :B  => %w(  ),
      :C  => %w(  ),
      :D  => %w(         D3  A3  D4  F#4 ),
      :E  => %w( E2  B2  E3  G#3 B3  E4  ),
      :F  => %w(  ),
      :G  => %w(  ),

      :Am => %w(     A2  E3  A3  C3  E4  ),
      :Bm => %w(  ),
      :Cm => %w(  ),
      :Dm => %w(         D3  A3  D4  F4  ),
      :Em => %w( E2  B2  E3  G3  B3  E4  ),
      :Fm => %w(  ),
      :Gm => %w(  ),
    }

  def self.method_missing(m, *args, &block)
    return @@chords[m] if @@chords.keys.include? m
    super
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

