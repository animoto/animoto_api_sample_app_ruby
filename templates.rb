template :layout do
  content = ""
  File.open("#{PartnerApp.root}/views/layouts/app.erb", "r") do |file|
    while (line = file.gets)
      content += line 
    end
  end
  content
end
