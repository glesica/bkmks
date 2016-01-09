#!/bin/sh

rm ~/.bkmksdb

./bkmks -a -t=tag0 -t=tag1 http://google.com
./bkmks -a -t=tag0 -t=tag2 http://www.yahoo.com
