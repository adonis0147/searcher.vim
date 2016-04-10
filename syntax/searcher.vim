syntax match searcherFilename /^.*\ze$/
syntax match searcherMatchedLine /^\d\+: /
syntax match searcherNotMatchedLine /^\d\+- /
syntax match searcherSepLine /^--/

highlight def link searcherFilename       Title
highlight def link searcherMatchedLine    SignColumn
highlight def link searcherNotMatchedLine LineNr
highlight def link searcherKeyword        MatchParen

