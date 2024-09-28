class Home::ShowPage < MainLayout
  needs currency : Currency

  def content
    h1 "Report!"
  end
end
