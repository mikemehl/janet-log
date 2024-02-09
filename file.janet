(import ./stamps)

(defn stamp->file [s f]
  (when (stamps/stamp? s)
    (let [stamp-str (stamps/stamp->string s)]
      (file/write f stamp-str))))

(defn create-or-open-file [fname mode]
  (when (not (os/stat fname))
    (let [f (file/open fname :w)]
      (file/flush f)
      (file/close f)))
  (file/open fname mode))

(defn stamps->file [ss fname]
  "Write the stamps to a file. Overwrites the file."
  (let [f (create-or-open-file fname :w)]
    (map (fn [s] (stamp->file s f)) ss)
    (file/flush f)
    (file/close f)))

(defn file->stamps [fname]
  (let [f (create-or-open-file fname :r)
        fstr (file/read f :all)
        ss (stamps/string->stamps fstr)]
    (file/close f)
    (when ss
      (map 
        (fn [s] (stamps/new-stamp (s 0) (s 1) (s 2) (s 3))) 
        ss))))

(def default-stamps-file ".stamps.txt")
