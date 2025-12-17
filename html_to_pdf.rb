require 'pdfkit'
require 'open-uri'
require 'nokogiri'

# This class converts an HTML book to a PDF book.
# Specifically, it works for books similar to "Learn C the Hard Way"
# where all of the links are on one page, and visiting each link and converting
# the HTML at the URL to a PDF is sufficient to capture all of the book's content.
class PDFBookMaker
  def initialize(url)
    @url = url # The URL of the book.
    @pages = [] # An array to hold the page filenames.
  end

  # Create a pdf for the URL specified by "a". "a" is the relative path.
  def create_pdf(a)
    puts "Converting #{a} to PDF"
    kit = PDFKit.new(@url + a)
    kit.to_pdf
    filename = a.gsub(/html/, "pdf")
    kit.to_file(filename)
    @pages.push(filename)
  end

  # Get user input and start creating the pdf.
  def create
    print "Enter the filename to which the PDF will be saved (no extension): "
    @filename = gets.chomp + ".pdf"

    print "Enter the first link to include (no .html): "
    first_link = gets.chomp + ".html"

    print "Enter the last link to include (no .html): "
    last_link = gets.chomp + ".html"

    # Access all of the links in the URL, starting from first_link
    # and ending at last_link. Write each page to pdf.
    found_first = false
    source = Nokogiri::HTML(open(@url))
    links = source.css("a")

    links.each do |link|
      a = link['href']
      if found_first or a.eql? first_link
        found_first = true
        if a.eql? last_link
          create_pdf(a)
          break
        else
          create_pdf(a)
        end
      end
    end
  end

  # Combine the pages into a single PDF using ghostscript.
  def combine_pages
    options = "-q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite"
    ghostscript = "gs #{options} -sOutputFile=#{@filename} "
    @pages.each do |page|
      ghostscript += "#{page} "
    end
    system ghostscript
    
  end

  # Get rid of intermediary pdfs.
  def cleanup
    @pages.each do |file|
      File::delete(file)
    end
  end 
end

# Get some information from the user that can be used to generate the pdf:
print "Enter a URL to convert to PDF: "
url = gets.chomp
book = PDFBookMaker.new(url)
book.create
book.combine_pages
book.cleanup
