import
  bkmks_models,
  bkmks_serialize

proc print*(b: Bkmk) =
  echo b.asRow

proc print*(bs: seq[Bkmk]) =
  for b in bs:
    b.print()
