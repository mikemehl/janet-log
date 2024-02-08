(defn all? [x]
  (all (fn [y] y) x))

(defn new-stamp [timestamp project tag start-stop]
  @{:timestamp timestamp
    :project project
    :tag tag
    :start-stop start-stop})

(defn stamp-now [start-stop &opt project tag] 
  @{:timestamp (os/time)
    :project (if project project "default")
    :tag (if tag tag "default")
    :start-stop (match start-stop 
                :start :start
                :stop :stop
                _ nil)})

(defn stamp? [s]
  (all? (map (fn [( k v )] -> 
    (match k
      :timestamp (number? v)
      :project (string? v)
      :tag (string? v)
      :start-stop 
        (match v
          :start true
          :stop true
          _ false))) 
    (pairs s))))

(defn stamp->string [s]
  (if (stamp? s)
    (string (s :timestamp) "|" (s :project) "|" (s :tag) "|" (s :start-stop) "\n")))

(def timestamp-capture '(<- :d+))
(def string-capture '(<- (some (+ :w "_" "-" ))))
(def start-stop-capture '(<- (choice "start" "stop")))
(def stamp-file-grammar 
  ~{ 
    :main (some (* :entry "\n"))
    :entry (group (* :timestamp "|" :project "|" :tag "|" :start-stop ))
    :timestamp ,timestamp-capture
    :project ,string-capture
    :tag ,string-capture
    :start-stop ,start-stop-capture
    })

(def stamp-file-peg (peg/compile stamp-file-grammar))

(peg/match stamp-file-peg 
  "1234567890|default|default|start\n12|maybe|maybe|stop\n")

(defn stamp->file [s f]
  (when (stamp? s)
    (let [stamp-str (stamp->string s)]
      (file/write f stamp-str))))

(defn stamps->file [ss fname]
  "Write the stamps to a file. Overwrites the file."
  (let [f (file/open fname :w)]
    (map (fn [s] (stamp->file s f)) ss)
    (file/flush f)
    (file/close f)))

(defn file->stamps [fname]
  (let [f (file/open fname :r)
        fstr (file/read f :all)
        ss (peg/match stamp-file-peg fstr)]
    (file/close f)
    (when ss
      (map 
        (fn [s] (new-stamp (s 0) (s 1) (s 2) (s 3))) 
        ss))))

(def f (file/open "test.txt" :r))
(def ss (file/read f :all))
(peg/match stamp-file-peg ss)
(file/close f)
(file->stamps "test.txt")

(defn main [args] 
  (print "Hello, World!"))
