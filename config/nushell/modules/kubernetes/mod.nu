export-env {
    use env.nu *
}

export def "kube-config" [] {
    let file = if ($env.KUBECONFIG? | is-empty) { $"($env.HOME)/.kube/config" } else { $env.KUBECONFIG }
    { path: $file, data: (cat $file | from yaml) }
}

use utils.nu *
use complete.nu *
export use functions.nu *   