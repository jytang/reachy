#!/bin/bash

gem build reachy.gemspec
ls *.gem | head -n 1 | xargs gem install -l
