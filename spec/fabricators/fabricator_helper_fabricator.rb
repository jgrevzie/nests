



# Remove nil values from input hash, select key value pairs and map keys if necessary
def opt_params *args
  opts = args.extract_options!
  # (first param is hash of attributes to select from)
  # rest of params are either a list of key names (to select) 
  # or a hash of key-key mappings (to change keys and select)
  
  # eliminate (k, v) pairs that have v=nil
  hash = args[0].delete_if {|k, v| v.nil?}

  # grab selected key value pairs from this hash, ignoring keys that don't exist in initial hash
  hash = hash.slice *args[1..-1].delete_if {|i| args[0][i].nil?}
  
  # into that hash merge another hash, consisting of the mapped key names specified in opts
  return hash.merge Hash[args[0].slice(*opts.keys).map {|k, v| [opts[k], v]}]
end