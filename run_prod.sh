#!/usr/bin/env bash

rbenv local 3.0.2

pkill -f app/poll
sleep 1
bundle exec ruby app/poll.rb
