# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
    spec.name           = "reachy"
    spec.version        = "1.0"
    spec.authors        = ["Thao Truong (Kainu)", "Joshua Tang"]
    spec.summary        = %q{Riichi Score Tracker}
    spec.files          = ["lib/reachy.rb"]
    spec.executables    = ["reachy"]
    spec.test_files     = ["tests/test_reachy.rb"]
    spec.require_paths  = ["lib"]
end
