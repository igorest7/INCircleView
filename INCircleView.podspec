#
#  Be sure to run `pod spec lint INCircleView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.

Pod::Spec.new do |s|

  s.name         = "INCircleView"
  s.version      = "1.0.0"
  s.summary      = "Lightweight component for drawing progress or indicator circles."

  s.description  = <<-DESC
A customisable circle progress or indicator view. Easily configurable in the interface builder, supports multiple different colours, background, empty fills, dash pattern and other tweaks. To take the headache out of calculating angles and makke it easily compatible with progress values all fill parameters are 0 to 1.
                   DESC

  s.homepage     = "https://github.com/igorest7/INCircleView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Igor Nakonetsnoi" => "igorest7@gmail.com" }
  s.social_media_url   = "https://www.linkedin.com/in/igornakonetsnoi/"
  s.platform     = :ios
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/igorest7/INCircleView.git", :tag => s.version }
  s.source_files  = 'INCircleView'

end
