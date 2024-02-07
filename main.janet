(defn all? [x]
  (all (fn [y] y) x))

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
    (string (s :timestamp) "|" (s :project) "|" (s :tag) "|" (s :start-stop))))

# Untested bro
(def stamp-file-grammar 
  '(any {:timestamp :d+ 
    _ "|" 
    :project (capture :w+)
    _ "|" 
    :tag (capture :w+) 
    _ "|" 
    :start-stop (choice "start" "stop")
    _ "\n"}))

(defn main [args] 
  (print "Hello, World!"))
