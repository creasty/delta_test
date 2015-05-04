describe DeltaTest do

  describe "::configure" do

    let(:options) do
      %i[
        base_path
        table_file
        files
      ]
    end

    it "should set default values" do
      options.each do |option|
        expect(DeltaTest.respond_to?(option)).to be(true)
        expect(DeltaTest.send(option)).not_to be_nil
      end
    end

    it "should change option values inside the block" do
      expect {
        DeltaTest.configure do |config|
          options.each_with_index do |option, i|
            config.send("%s=" % option, i)
          end
        end
      }.not_to raise_error

      options.each_with_index do |option, i|
        expect(DeltaTest.send(option)).to eq(i)
      end
    end

  end

end
