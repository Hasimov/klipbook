require 'spec_helper'

# This is more of an integration test but what the heck
# it can live in here for now

describe Klipbook::ToHtml::HtmlPrinter do

  before(:all) do
    @output_dir = Dir.mktmpdir
  end

  after(:all) do
    FileUtils.rm_f(@output_dir)
  end

  let(:book) do
    Klipbook::Book.new.tap do |b|
      b.title = 'Fake book title'
      b.author = 'Fake Author'
      b.clippings = []
    end
  end

  let(:message_stream) do
    double(puts: nil)
  end

  describe '#print_to_file' do

    subject { Klipbook::ToHtml::HtmlPrinter.new(message_stream).print_to_file(book, @output_dir, force) }

    let(:force) { false }

    let(:expected_filename) { "Fake book title by Fake Author.html" }
    let(:expected_filepath) { "#{@output_dir}/Fake book title by Fake Author.html" }

    context 'with no existing summary file' do
      before(:each) do
        FileUtils.rm_f(File.join(@output_dir, '*'))
      end

      it 'writes a file named after the book into the output directory' do
        subject
        expect(File.exists?(expected_filepath)).to be_truthy
      end

      it 'writes a html summary to the file' do
        subject
        expect(File.read(expected_filepath)).to include("<h1>Fake book title</h1>")
      end
    end

    context 'with an existing summary file' do
      before(:each) do
        FileUtils.rm_f(expected_filepath)
        FileUtils.touch(expected_filepath)
      end

      context "and 'force' set to false" do
        let(:force) { false }

        it "won't write to the file" do
          subject
          expect(File.size(expected_filepath)).to eq 0
        end

        it 'prints a message informing that the file is being skipped' do
          subject
          expect(message_stream).to have_received(:puts).with("\e[33mSkipping \e[0m#{expected_filename}")
        end
      end

      context "and 'force' set to true" do
        let(:force) { true }

        it 'overwrites the file' do
          subject
          expect(File.size(expected_filepath)).to be > 0
        end

        it 'prints a message informing that the file is being written' do
          subject
          expect(message_stream).to have_received(:puts).with("\e[32mWriting \e[0m#{expected_filename}")
        end
      end
    end
  end
end
