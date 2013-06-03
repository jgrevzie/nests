



# Extract key value pairs from input hash, mapping keys if necessary
def opt_params *args
  opts = args.extract_options!
  # (first param is hash of attributes to select from)
  # rest of params are either a list of key names (to select) 
  # or a hash of key-key mappings (to change keys and select)
  
  # select key value pairs from initial hash, minus any that are nil
  hash = args[0].slice *args[1..-1].delete_if {|i| args[0][i].nil?}
  
  # select key value pairs again, but map key names
  return hash.merge Hash[args[0].slice(*opts.keys).map {|k, v| [opts[k], v] if v}]
end