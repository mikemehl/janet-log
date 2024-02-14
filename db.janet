(import ./stamps)

(def- default-db "stamps.ji")

(var- stamp-db @{})

(defn add [stamp]
  (let [{:project p :tag t :start-stop ss} stamp]
    (unless (get stamp-db p) (put stamp-db p @{}))
    (let [pdb (get stamp-db p)]
      (unless (get pdb t) (put pdb t @[]))
      (match [(get (array/peek (get pdb t)) :start-stop) ss]
        [:start :stop] (array/push (get pdb t) stamp)
        [:stop :start] (array/push (get pdb t) stamp)
        [nil :start] (array/push (get pdb t) stamp)
        _ false))))


(defn lookup [&opt project tag]
  (let [p (get stamp-db (or project "default"))]
    (if p
      (let [t (get p (or tag "default"))]
        (if t t false))
      false)))

(defn projects [] (keys stamp-db))

(defn current []
  (let [current-stamps @[]]
    (loop [p :keys stamp-db]
      (loop [t :keys (get stamp-db p)]
        (array/push current-stamps (last (get (get stamp-db p) t)))))
    current-stamps))

(defn clear []
  (set stamp-db @{}))

(defn init []
  (if (os/stat default-db)
    (do
      (set stamp-db (unmarshal (slurp default-db)))
      true)
    false))

(defn flush []
  (let [f (or (file/open default-db :wb) (os/open default-db :c :w))]
    (file/write f (marshal stamp-db))
    (file/close f)))

(defn dump []
  (loop [p :keys stamp-db]
    (let [proj (get stamp-db p)]
      (loop [t :keys proj]
        (each stamp (get proj t)
          (print (stamps/stamp->string stamp))))))
  true)
