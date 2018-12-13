import
  uri

type
  Bkmk* = object
    id*: int
    url*: string

func domain*(b: Bkmk): string =
  parseUri(b.url).hostname
