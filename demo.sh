#!/bin/sh

rm -f ~/.bkmksdb

./bkmks add -t=tag0 -t=tag1 http://google.com
./bkmks add -t=tag0 -t=tag2 http://www.yahoo.com
