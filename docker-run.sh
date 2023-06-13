#!/bin/bash

docker run --rm --name mattherman.github.io --volume="$PWD:/srv/jekyll" -p 4000:4000 -it jekyll/jekyll:3.8.5 jekyll serve --watch --drafts
