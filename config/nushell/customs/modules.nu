
export def ollama-update-models [] {
  ollama list | tail -n +2 | awk '{print $1}' | lines | each { |model| ollama pull $model }
}

# def "nu-complete git branches" [] {
#     git branch
#     | lines
#     | filter {|x| not ($x | str starts-with '*')}
#     | each {|x| $"($x|str trim)"}
# }

# export def gco [branch: string@"nu-complete git branches"] {
#     git checkout $branch
# }