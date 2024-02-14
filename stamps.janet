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
  (all? (map (fn [(k v)] ->
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
    (string (os/strftime "%Y-%m-%d @ %H:%M:%S" (s :timestamp) true) 
            "|" (s :project) "|" (s :tag) "|" (s :start-stop))))

(def timestamp-capture '(<- :d+))
(def string-capture '(<- (some (+ :w "_" "-"))))
(def start-stop-capture '(<- (choice "start" "stop")))
(def stamp-file-grammar
  ~{:main (some (* :entry "\n"))
    :entry (group (* :timestamp "|" :project "|" :tag "|" :start-stop))
    :timestamp ,timestamp-capture
    :project ,string-capture
    :tag ,string-capture
    :start-stop ,start-stop-capture})


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

(defn stamps->project-tags [ss]
  (sort (map (fn [s] {:project (s :project) :tag (s :tag)}) ss)))

(defn sort-stamps [ss]
  (sort-by (fn [s] (get s :timestamp)) ss))

(defn stamps->project-map [ss]
  "Convert a list of timestamps to a nested map. Index by project, then by tag."
  (var pm @{})
  (each s ss
    (do
      (def pkey (get s :project))
      (def tkey (get s :tag))
      (unless (get pm pkey) (put pm pkey @{}))
      (unless (get (pm pkey) tkey) (put (pm pkey) tkey @[]))
      (array/push ((pm pkey) tkey) s)))
  pm)
