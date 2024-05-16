use complete.nu *

# Kubernetes swtich namespace
export def kns [namespace: string@"nu-complete kube ns"] {
    if not ($namespace in (kubectl get namespace | from ssv -a | get NAME)) {
        if ([no yes] | input list $"namespace '($namespace)' doesn't exist, create it?") in [yes] {
            kubectl create namespace $namespace
        } else {
            return
        }
    }
    kubectl config set-context --current $"--namespace=($namespace)"
}

# Kubectl get
export def kg [
    kind: string@"nu-complete kube kind"
    resource?: string@"nu-complete kube res"
    --namespace (-n): string@"nu-complete kube ns" # Namespace
    --jsonpath (-p): string@"nu-complete kube jsonpath"
    --selector (-l): string
    --verbose (-v)
    --watch (-w) # Watch for changes
    --wide (-W)
    --all (-a)
] {
    let n = if $all {
                [-A]
            } else if ($namespace | is-empty) {
                []
            } else {
                [-n $namespace]
            }
    if ($resource | is-empty) {
        let l = $selector | with-flag -l
        if ($jsonpath | is-empty) {
            let wide = if $wide {[-o wide]} else {[]}
            if $verbose {
                kubectl get -o json ...$n $kind ...$l | from json
                | get items
                | krefine $kind
            } else if $watch {
                kubectl get ...$n $kind ...$l ...$wide --watch
            } else {
                kubectl get ...$n $kind ...$l ...$wide | from ssv -a | normalize-column-names
            }
        } else {
            kubectl get ...$n $kind $"--output=jsonpath={($jsonpath)}" | from json
        }
    } else {
        let o = kubectl get ...$n $kind $resource -o json | from json
        if $verbose { $o } else { $o | krefine $kind }
    }
}

# kubectl describe
export def kd [
    kind: string@"nu-complete kube kind"
    resource: string@"nu-complete kube res"
    --namespace (-n): string@"nu-complete kube ns"
] {
    kubectl describe ...($namespace | with-flag -n) $kind $resource
}