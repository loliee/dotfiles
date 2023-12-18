# Zellij

if test $TERMINAL_MULTIPLEXER = "zellij"; and test -z "$ZELLIJ"
  zellij attach -c "ML"
end