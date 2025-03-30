# frozen_string_literal: true

module INat
  module Report
  end
end

class INat::Report::Table

  attr_reader :columns

  def initialize
    @columns = []
    @rows = []
    @line_no = 0
  end

  def column title, width: nil, align: nil, data: nil, marker: false, &block
    if data == nil && !block_given?
      raise ArgumentError, "Data argument or block must be provided!", caller
    end
    @columns << {
      title:  title,
      width:  width,
      align:  align,
      data:   data,
      marker: marker,
      block:  block
    }
  end

  private :column

  def row **data
    if !data.has_key?(:line_no)
      @line_no += 1
      data[:line_no] ||= @line_no
    end
    @rows << data
  end

  def rows *data
    data.each do |r|
      row(**r)
    end
    @rows
  end

  def empty?
    @rows.empty?
  end

  def << data
    if Array === data
      rows(*data)
    elsif Hash === data
      row(**data)
    else
      raise TypeError, "Invalid data type: #{ data.inspect }!", caller
    end
  end

  private def th column
    style = ""
    case column[:width]
    when Numeric
      style += "width:#{ column[:width] }em;"
    when String
      style += "width:#{ column[:width] };"
    end
    style += "text-align:#{ column[:align] };" if column[:align]
    if style.empty?
      "<th>#{ column[:title] }</th>"
    else
      "<th style=\"#{ style }\">#{ column[:title] }</th>"
    end
  end

  private def header
    result = []
    result << "<tr>"
    result += @columns.map { |c| th(c) }
    result << "</tr>"
    result.join ""
  end

  private def td column, row
    inner = case column[:data]
    when String, Symbol
      row[column[:data].intern]
    when Proc
      column[:data].call row
    when nil
      column[:block].call row
    end
    inner = inner.to_html if inner.respond_to?(:to_html)
    style = ""
    case column[:width]
    when Numeric
      style += "width:#{ column[:width] }em;"
    when String
      style += "width:#{ column[:width] };"
    end
    style += "text-align:#{ column[:align] };" if column[:align]
    marker = nil
    if column[:marker]
      anchor = row[:anchor]
      marker = "<a name=\"#{ anchor }\"></a>"
    end
    if style.empty?
      "<td>#{ marker }#{ inner }</td>"
    else
      "<td style=\"#{ style }\">#{ marker }#{ inner }</td>"
    end
  end

  private def row_to_html row
    result = []
    result << "<tr#{ row[:style] ? " style=\"#{ row[:style] }\"" : '' }>"
    result += @columns.map { |c| td(c, row) }
    result << "</td>"
    result.join "\n"
  end

  def to_html
    result = []
    result << "<table>"
    result << header
    result += @rows.map { |r| row_to_html(r) }
    result << "</table>"
    result.join "\n"
  end

end

module INat::Report::Table::DSL

  include INat::Report

  def table &block
    tbl = Table::new
    tbl.instance_eval(&block) if block_given?
    tbl
  end

  module_function :table

end
