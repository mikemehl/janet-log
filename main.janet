(import ./stamps)
(import ./db)
(import spork/argparse)

(defn cmd-add [ss &opt p t]
  (if (or (= ss :start) (= ss :stop))
    (let [s (stamps/stamp-now ss p t)]
      (db/add s))))

(defn cmd-dump [] (db/dump))


(defn main [& args]
  (let [args (dyn :args)]
    (pp args)
    (if (< 2 (length args))
      (let [cmd (get args 2)]
        (print cmd))
      (print "NOPE"))))
