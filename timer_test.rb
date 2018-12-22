require_relative './lib/session'

session = Session.new(1, 2)
sleep 1
session.touch
sleep 2
session.touch
sleep 3
session.touch
sleep 4
session.touch
sleep 5
session.touch
sleep 7
