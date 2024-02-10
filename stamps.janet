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
(def string-capture '(<- (some (+ :w "_" "-"))))
(def start-stop-capture '(<- (choice "start" "stop")))
(def stamp-file-grammar 
  ~{ 
    :main (some (* :entry "\n"))
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

(defn stamps->proj-set [ss]
  (let [proj-set @{}]
    (reduce (fn [ps s] (put ps (s :project) true))
      proj-set ss)))

(defn stamp->pt-set-key [s]
  (string (s :project) "|" (s :tag)))

(defn stamps->pt-set [ss]
  (reduce (fn [pts s]
           (put pts (stamp->pt-set-key s) (array)))
          @{} ss))

(defn pt-set-mark-stamp [pts s]
  (let [key (stamp->pt-set-key s)
        start-stop (s :start-stop)]
    (if (= start-stop :start)
      (array/push (pts key) true)
      (array/pop (pts key)))
    pts))

(defn balanced? [ss]
  "Returns true if starts and stops are balanced for every project-tag pair"
  (let [pts (stamps->pt-set ss)]
    (reduce 
      (fn [pt-set s] 
        (if (pt-set-mark-stamp pts s) pts false))
      pts ss))) 
         
        
(def pts (stamps->pt-set ss))
(pt-set-mark-stamp pts a)
(balanced? ss)
        
  
          
(empty? (values @{:a @[true]})) 


(def thing @{:hello @[]})
(array/pop (thing :hello))

(def pts @{})
(def a (stamp-now :start))
(def b (stamp-now :stop))
(def c (stamp-now :start))
(def d (stamp-now :stop))
(def e (stamp-now :stop))
(def ss [a b c d])

(pp (balanced? ss))
