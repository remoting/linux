# brew install lrzsz

# apt install lrzsz

# config
```
Create triggers under Profiles -> Advanced:

  Regular expression: rz waiting to receive.\*\*B0100
  Action: Run Silent Coprocess
  Parameters: /usr/local/bin/iterm2-send-zmodem.sh
  Instant: checked

  Regular expression: \*\*B00000000000000
  Action: Run Silent Coprocess
  Parameters: /usr/local/bin/iterm2-recv-zmodem.sh
  Instant: checked

```