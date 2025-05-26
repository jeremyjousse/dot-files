
export def display_hello_on_startup [] {
  let hints = [
    "Think about reading https://www.namtao.com/oxidise-your-cli-2025/",
    "Use Eza (eza) to list files with colors and icons.",
    "Use Ripgrep (rg) to search files quickly.",
    "Use Tokei (tokei) to count lines of code in your projects.",
    "Use Bat (bat) to view files with syntax highlighting.",
    "Use Fzf (fzf) for fuzzy file searching.",
    "Use Zoxide (zoxide) for fast directory navigation.",
  ]
  let random_hint = $hints | shuffle | get 1
  print $"ℹ️ ($random_hint)"
}

display_hello_on_startup