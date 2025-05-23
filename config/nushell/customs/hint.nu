
export def display_hello_on_startup [] {
  let hints = [
    "Think about reading https://www.namtao.com/oxidise-your-cli-2025/",
    "Use Eza to list files with colors and icons.",
    "Use Ripgrep to search files quickly.",
  ]
  let random_hint = $hints | shuffle | get 1
  print $"ℹ️ ($random_hint)"
}

display_hello_on_startup