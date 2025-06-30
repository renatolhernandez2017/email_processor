File.open("#{Rails.root}/public/representatives.csv", "rb") do |file|
  csv_enum = CSV.new(
    file.read.encode("UTF-8", invalid: :replace, undef: :replace, replace: ""),
    col_sep: ","
  )

  csv_enum.each do |row|
    number = row[0]&.strip
    name = row[1]&.strip
    branch_name = row[2]&.strip
    partnership = row[3]&.strip
    performs_closing = row[4]&.strip

    new_name = if name == "N/A"
      name
    else
      name_fun = name.downcase.tr("_", " ")
      parts = name_fun.split.map(&:capitalize)

      if parts.length > 1 && parts.last.length <= 1
        parts.pop
      end

      parts.join(" ")
    end

    branch = Branch.search_global(branch_name.capitalize).last

    Representative.create!(
      number: number, name: new_name, branch: branch, active: true,
      partnership: partnership, performs_closing: performs_closing 
    )
  end
end
