import
  sequtils,
  strutils

proc parseIds*(ids: var seq[int], rawIds: string) =
  ## Parse `rawIds` and add all IDs produced as a result to
  ## the `ids` sequence. The sequence is mutated.
  let newIds = split(rawIds, ",")
      .map(parseInt)
  for id in newIds:
    ids.add(id)

proc parseTags*(tags: var seq[string], rawTags: string) =
  ## Parse `rawTags` and add all tags produced as a result to
  ## the `tags` sequence. The sequence is mutated.
  let newTags = split(rawTags, ",")
      .map(toLower)
      .map(func (tag: string): string = tag.strip(true, true, Whitespace))
  for tag in newTags:
    tags.add(tag)
