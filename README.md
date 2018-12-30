# Intallation
```
make setup
```

# Strating application
```
make run
# or with custom sessions expire time in seconds
make run EXPIRE_SECONDS=10 # default 6
```

# Storages
To use redis (connects to default localhost/0)
```
make run STORAGE=redis
```
Thread havy PORO storage (defaul)
```
make run STORAGE=poro
```
Less threaded and less accuracy PORO storage
```
make run STORAGE=poro_time_bucket
```

# Lint and test
```
make lint
make test
```

# Handy dev things
```
make console
ruby spec/dev_helpers/dummy_load.rb
```
