
export def ollama-update-models [] {
  ollama list | tail -n +2 | awk '{print $1}' | lines | each { |model| ollama pull $model }
}

export def open-webui [] {
  docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
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