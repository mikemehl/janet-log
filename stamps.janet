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

(defn string->stamps [s]
  (peg/match stamp-file-peg s))

(defn stamps->projects [ss]
  (map (fn [s] (s :project)) ss))

(defn stamps->tags [ss]
  (map (fn [s] (s :tag)) ss))

(defn stamps->start-stop [ss]
  (map (fn [s] (s :start-stop)) ss))

(defn stamps->timestamps [ss]
  (map (fn [s] (s :timestamp)) ss))

(defn stamps->proj-set [ss]
  (let [proj-set @{}]
    (reduce (fn [ps s] (put ps (s :project) true))
      proj-set ss)))

# TODO: This doesn't work.
# Maybe we don't need to build these sets?
# Probably easier to just walk the list and 
# build stacks as we go.
# Push when you see start, pop when you see stop.
# Maybe just concat the project and tag into a string
# and use that as the key in a map.
(defn proj-set->proj-tag-set [ps ss]
  (let [pts @{}] 
    (each [proj _] ps 
      (put pts proj 
        (reduce (fn [ts s] 
          (when (= (s :project) proj)
            (put ts (s :tag) true))) @{} ss)))))

(def pts @{})
(def ps (stamps->proj-set [a b c d]))
(proj-set->proj-tag-set ps [a b c d])

(doc each)
(each [k v] @{:yo "what"} (pp "hey"))

(defn verify-stamps [ss])

(def a (stamp-now :start))
(def b (stamp-now :stop))
(def c (stamp-now :start))
(def d (stamp-now :stop))
(def ss [a b c d])
(stamps->start-stop ss)
