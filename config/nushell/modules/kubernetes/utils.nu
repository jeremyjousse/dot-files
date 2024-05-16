export def ensure-cache-by-lines [cache path action] {
    if not ($cache | path exists) {
        mkdir ($cache | path dirname)
        {
            lines: ""
            payload: {}
        } | save -f $cache
    }
    let ls = do -i { open $path | lines | length }
    if ($ls | is-empty) { return false }
    let lc = do -i { open $cache | get lines}
    if not (($cache | path exists) and ($lc | is-not-empty) and ($ls == $lc)) {
        mkdir ($cache | path dirname)
        {
            lines: $ls
            payload: (do $action)
        } | save -f $cache
    }
    (open $cache).payload
}

export def --wrapped with-flag [...flag] {
    if ($in | is-empty) { [] } else { [...$flag $in] }
}

export def normalize-column-names [ ] {
    let i = $in
    let cols = $i | columns
    mut t = $i
    for c in $cols {
        $t = ($t | rename -c {$c: ($c | str downcase | str replace ' ' '_')})
    }
    $t
}