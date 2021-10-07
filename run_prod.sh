#!/usr/bin/env bash

pkill -f app/poll
sleep 1
bundle exec ruby app/poll.rb
