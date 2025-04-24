require "tilt/erubis"
require "sinatra"
require "sinatra/reloader"

MODE = 'DEV'
B = MODE == 'DEV' ? '' : '/sherlock'

before do
  @toc = File.readlines "data/toc.txt"
end

helpers do
  # def slugify(text)
  #   text.downcase.gsub(/\s+/, "-").gsub(/[^\w-]/, "")
  # end
  def in_paragraphs(text)
    paragraphs = []
    text.split("\n\n").each_with_index { |para, idx| paragraphs << "<p id=paragraph#{idx}>#{para}</p>" }
    paragraphs.join("")
  end

  def search(query)
    return nil if query.nil?

    num_files = Dir.entries("./data/").select { |entry| !File.directory?(entry) && entry != "toc.txt" }
    p num_files.length

    results = []
    num_files.each_with_index do |_, ch_idx|
      txt_paras = File.read("./data/chp#{ch_idx + 1}.txt").split("\n\n")
      
      paras = []
      txt_paras.each_with_index do |paragraph, p_idx|
        if paragraph.include?(query)
          new_text = paragraph.gsub(query, "<strong>#{query}</strong>")
          paras << {para_num: p_idx, para_txt: new_text} 
        end
      end

      results << { chptr_num: ch_idx + 1, chptr_title: @toc[ch_idx][0..-2], paras: paras } unless paras.empty?
    end
    # p results
    results
  end
end

get "/chapters/:num" do
  redirect "/" unless (1..@toc.length).cover?(params['num'].to_i)

  @title = "Chapter #{params['num']} - #{@toc[params['num'].to_i - 1]}"
  @txt = in_paragraphs File.read "data/chp#{params['num']}.txt"

  erb :chapter
end

get "/" do 
  @title = "Sherlock Holmes"
  erb :home
end

get "/search" do
  @results = search(params['query'])
  erb :search
end

not_found do
  redirect "/"
end

