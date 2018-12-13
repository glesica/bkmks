import
  strutils

import
  bkmks_models

proc asRow*(b: Bkmk): string =
  intToStr(b.id) & '\t' & b.url
