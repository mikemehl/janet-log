(import spork/argparse)
(import ./stamps)
(import ./file)

(def flags-spec [:file {:kind :flag 
  :short "-f" 
  :long "--file" 
  :help "The file to read/write stamps from/to."
   :required false 
  :default default-stamps-file}])

(defn parse-args [args]
  (match args 
    ["start" project tag] (stamps/stamp-now :start project tag)
    ["stop"  project tag] (stamps/stamp-now :stop project tag)
    ["start" project] (stamps/stamp-now :start project)
    ["stop"  project] (stamps/stamp-now :stop project)
    ["start"] (stamps/stamp-now :start)
    ["stop"] (stamps/stamp-now :stop)
    ["list"] (file/file->stamps default-stamps-file)
    _ nil))

# TODO: Parse the args and let 'er rip.
# Might want to add a return value to file->stamps if it
# doesn't have one so you can check if the file was read.
# Also, you'll have to read the file to write it with the
# way you've written things. Either change that or bite 
# the bullet and do it.
# (argparse/argparse)

(defn main [args] 
  (print "Hello, World!"))

