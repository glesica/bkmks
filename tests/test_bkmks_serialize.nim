import
  unittest,
  bkmks_models,
  bkmks_serialize

suite "bkmks_serialize":
  suite "asRow":
    test "should return a tab-delimited string of id and url":
      let bkmk = Bkmk(id: 0, url: "url")
      let row = bkmk.asRow
      check(row == "0\turl")
    
    test "should return a correct string when id is large":
      let bkmk = Bkmk(id: 9999999, url: "url")
      let row = bkmk.asRow
      check(row == "9999999\turl")
