(import ./stamps)
(import ./db)
(import spork/argparse)

(defn cmd-start [args]
  (db/init)
  (let [ts (match args
             [p t] (stamps/stamp-now :start p t)
             [p] (stamps/stamp-now :start p)
             _ (stamps/stamp-now :start))]
    (pp (stamps/stamp->string ts))
    (if (db/add ts)
      (db/flush)
      (pp "Error: could not add stamp."))))

(defn cmd-stop [args]
  (db/init)
  (let [ts (match args
             [p t] (stamps/stamp-now :stop p t)
             [p] (stamps/stamp-now :stop p)
             _ (stamps/stamp-now :stop))]
    (pp (stamps/stamp->string ts))
    (if (db/add ts)
      (db/flush)
      (pp "Error: could not add stamp."))))

(defn cmd-dump [] (db/init) (db/dump))

(defn cmd-list [args]
  (db/init)
  (let [p (get args 0) t (get args 1)]
    (if (= p nil)
      (pp "Error: must specify a project.")
      (let [stamps (db/lookup p t)]
        (each s stamps (pp (stamps/stamp->string s)))))))

(defn cmd-status []
  (db/init)
  (let [stamps (db/current)]
    (each line
      (map (fn [{:start-stop ss :project p :tag t}]
             (when (= ss :start)
               (string "Running: " p ", " t)))
           stamps)
      (when line (print line)))))

(defn route-cmd [args]
  (let [[_ cmd & rest] args]
    (match cmd
      "dump" (cmd-dump)
      "start" (cmd-start rest)
      "stop" (cmd-stop rest)
      "list" (cmd-list rest)
      "status" (cmd-status))))

(defn main [& args]
  (let [args (dyn :args)]
    (pp args)
    (route-cmd args)))
