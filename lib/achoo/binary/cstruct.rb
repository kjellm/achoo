require 'achoo/binary'

class Achoo::Binary::CStruct

  def initialize(bytes=nil)
    @values = []
    unpack(bytes) unless bytes.nil?
  end

  class << self

    attr :template

    def inherited(subclass)
      subclass.instance_variable_set(:@template, '') 
      subclass.instance_variable_set(:@count, 0)
    end 

    def char(name);  add_type(name, :char,  'c', 0); end
    def short(name); add_type(name, :short, 's', 0); end
    def long(name);  add_type(name, :long,  'l', 0); end
    def quad(name);  add_type(name, :quad,  'q', 0); end

    def string(name, length); add_type(name, :string, 'A', '', length); end

    def bin_size
      @bin_size ||= template.split('').select {|c| c =~ /[[:alpha:]]/}.map do |c|
        c == 'A' ? '' : 0
      end.pack(template).length
    end

    private 

    def add_type(name, type, temp, zero, length=nil)
      template << temp
      template << length.to_s if type == :string
      index = @count
      @count += 1

      send(:define_method, name) do
        @values[index]
      end

      send(:define_method, "#{name}=") do |val|
        @values[index] = val
      end
    end

  end

  def unpack(str)
    @values = str.unpack(self.class.template)
  end

  def pack
    t = self.class.template.tr('A', 'a')
    @values.pack(t)
  end

end
