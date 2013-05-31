# functions
qr|function\s+(?:(?:\[[^]]+\]\|[[:alnum:]_]+)\s*=\s*)?([[:alnum:]_]+)\s*(\([^)]*\))|mx
#qr|^function\s+(?:(?:\[[^]]+\]\|[[:alnum:]_]+)\s*=\s*)?([[:alnum:]_]+)\s*(\([^)]*\))|
# globals
qr|^global((?:[ \t]+[[:alnum:]_]+)+)|x
