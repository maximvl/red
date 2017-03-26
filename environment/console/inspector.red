Red [
  Title:	"Red console inspector"
  Author: ["Maxim Velesyuk"]
  File:   %inspector.red
  Rights: "Copyright (C) 2017 Maxim Velesyuk. All rights reserved."
  License: {
    Distributed under the Boost Software License, Version 1.0.
    See https://github.com/red/red/blob/master/BSL-License.txt
  }
]

system/console/inspector: context [
   initial-words: sort keys-of system/words
   groups: #()

   group: func [words /local acc s t] [
      acc: copy #()
      forall words [
         error? try [
            either s: select acc t: type? get words/1 [
               append s words/1
            ] [
               extend acc compose/deep [(t) [(words/1)]]
            ]
         ]
      ]
      acc
   ]

   init: does [
      remove-each word initial-words [ not value? in system/words word ]
      groups: group initial-words
   ]

   make-diff: func [/local t] [
     t: difference initial-words keys-of system/words
     remove-each word t [ not value? in system/words word ]
     t
  ]

   filter: func [series pred] [
      collect [
         forall series [
            if pred series/1 [keep series/1]
         ]
      ]
   ]

   make-words: func [types /local words] [
      words: copy []
      if types/system [ append words initial-words ]
      if types/user   [ append words make-diff ]
      ; TODO add functions, datatypes, constants etc
      forall words [ words/1: to-string words/1 ]
      words
   ]

   show: func [/local spec words sys-words user-words search list desc] [
      unless system/console/gui? [
         throw "Console is running without gui"
      ]
      spec: object [system: on user: on]
      words: make-words spec
      view [
         title "Red Inspector"
         below
         text "Words"
         sys-words:  check "System words" data spec/system [
            spec/system: sys-words/data
            list/data: words: make-words spec
         ] 150
         user-words: check "User words" data spec/user [
            spec/user: user-words/data
            list/data: words: make-words spec
         ] 150
         search: field on-change [
            list/data: either empty? search/text [words] [
               filter words func [w] [ find w search/text ]
            ]
         ] 150
         list: text-list [desc/text: fetch-help to-word pick list/data list/selected ] data words 150x300
         return
         text "Description"
         desc: text "Select the word to display" 300x300
      ]
   ]
]
