# pi
Pico HTTP server for tests, prototype or a small application.
pi is listening on port 8080.

This GitHub repository hosts several versions of pi, written in Crystal and Ruby.


# Crystal

## Build

```
cd Crystal
shards install
crystal build --progress src/pi.cr
cd ..
```

## Run

```
Crystal/pi
```


# Ruby

No build.

## Run

```
rackup -p 8080
```


# Usage

Use this [pi server](http://localhost:8080) with your favorite browser.

