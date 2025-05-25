export def ollama-update-models [] {
  ollama list | tail -n +2 | awk '{print $1}' | lines | each { |model| ollama pull $model }
}

export def open-webui [] {
  docker run -d -p 3000:8080 --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
}


export def book-clean []  {
  let ebooks = ls | where type == "file" | where name =~ ".pdf|epub$"
  print $"Found {($ebooks | length)} ebooks to clean."
  if ($ebooks | is-empty) {
    print "No ebooks found to clean."
  } else {
    const editors = [
    'Apress',
    'Manning',
    'No Starch Press',
    'Oreilly',
    'OReilly',
    'Packt',
    'Pragmatic Bookshelf',
    'Razeware LLC',
    'Routledge',
    'Wiley',
  ];


    $ebooks | each { |ebook| 
      mut cleaned_name = $ebook.name | str replace --all '-' ' ' | str replace '_' ' '
      
      for editor in $editors {
        if ($cleaned_name | str starts-with $"($editor) ") {
          $cleaned_name = $cleaned_name | str replace $"($editor) " ""
        }
      }
      
      if ($cleaned_name != $ebook.name) {
        mv $ebook.name $cleaned_name
      } 
    }
  }
}

# export def gco [branch: string@"nu-complete git branches"] {
#     git checkout $branch
# }

