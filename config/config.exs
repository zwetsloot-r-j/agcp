use Mix.Config

config :clipboard,
  unix: [
    copy: {"xclip", ["-in", "-selection", "clipboard"]},
    paste: {"xclip", ["-out", "-selection", "clipboard"]}
  ]
