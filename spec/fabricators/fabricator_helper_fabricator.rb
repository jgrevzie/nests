



def opt_params *args
  opts = args.extract_options!
  # (first param is the hash of attributes)
  # rest of params are either a list of key names or a hash of key-key mappings
  return args[0].slice *args[1..-1] if opts.size==0
  return Hash[args[0].slice(*opts.keys).map {|k, v| [opts[k], v] if v}]
end