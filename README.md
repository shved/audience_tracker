# Strating application
```ruby
make run
# or with custom sessions expire time in seconds
make run EXPIRE_SECONDS=10
```

# Storages
To use redis run as. Uses default localhost/0
```ruby
make run STORAGE=redis
```
Thread havy PORO storage (defaul)
```ruby
make run STORAGE=poro
```
Less threaded and less accuracy PORO storage
```ruby
make run STORAGE=poro_time_bucket
```

# Lint and test
```ruby
make lint
make test
```

# Handy console
```ruby
make console
```
