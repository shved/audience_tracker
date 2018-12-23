# Strating application
```
make run
# or
make run APP_ENV=production
```
To use redis run as
```
make run STORAGE=redis://username:password@host:port/db
# or locally
make run STORAGE=redis://127.0.0.1:6379
```

# Lint
```
make lint
```
