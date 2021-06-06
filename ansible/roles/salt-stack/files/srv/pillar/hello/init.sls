schedule:
  hello:
    function: cmd.run
    seconds: 10
    args:
      - "echo hello >> /tmp/hello"
