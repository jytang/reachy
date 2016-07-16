# coding: utf-8
Gem::Specification.new do |spec|
    spec.name           = "reachy"
    spec.version        = "1.0"
    spec.authors        = ["Thao Truong (Kainu)", "Joshua Tang"]
    spec.email          = "someone@nowhere.com"
    spec.homepage       = "https://reachy.herokuapp.com"
    spec.license        = 'WTFPL'
    spec.summary        = %q{Riichi Score Tracker}
    spec.files          = Dir.glob("{bin,lib,data}/**/*")
    spec.test_files     = ["tests/test_reachy.rb"]
    spec.require_paths  = ["lib"]
    spec.executables    = ["reachy"]
end
