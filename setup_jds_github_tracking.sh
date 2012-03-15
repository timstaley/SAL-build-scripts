#!/bin/sh
git remote add -t master jds https://github.com/jdswinbank/tkp-lofar-build.git
git fetch jds
git branch --set-upstream amsterdam jds/master

