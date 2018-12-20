`curl --get localhost:9292/heartbeat -d customer_id=1 -d video_id=1`
sleep(0.3) # there is still no mutex
`curl --get localhost:9292/heartbeat -d customer_id=1 -d video_id=2`
sleep(0.3) # there is still no mutex
`curl --get localhost:9292/heartbeat -d customer_id=1 -d video_id=3`
sleep(0.3) # there is still no mutex
`curl --get localhost:9292/heartbeat -d customer_id=2 -d video_id=1`
sleep(0.3) # there is still no mutex
`curl --get localhost:9292/customers/1`
sleep(0.3) # there is still no mutex
`curl --get localhost:9292/videos/1`
