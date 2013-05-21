



# Extract key value pairs from input hash, mapping keys if necessary
def opt_params *args
  opts = args.extract_options!
  # (first param is hash of attributes)
  # rest of params are either a list of key names or a hash of key-key mappings
  hash = args[0].slice *args[1..-1].delete_if {|i| args[0][i].nil?}
  return hash.merge Hash[args[0].slice(*opts.keys).map {|k, v| [opts[k], v] if v}]
end