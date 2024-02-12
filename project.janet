(declare-project 
  :name "log"
  :description "A CLI time tracker"
  :dependencies ["https://github.com/janet-lang/spork.git"
                 { :url "https://github.com/ianthehenry/judge.git" :tag "v2.8.1"}])

(declare-executable
  :name "log" 
  :entry "main.janet")
