export def get-config [variables_path: string, tags_path: string] {
    print "info: getting config..."

    let variables = read-variables $variables_path

    mut variables = (add-env-variables $variables)
    $variables = (add-tags-variable $variables $tags_path)

    validate-variables-or-exit $variables

    return $variables
}

export def add-env-variables [variables] {
    let from_env_variables = {
        aws_region: (try { $env.AWS_REGION })
    }

    return {
       ...$variables,
       aws_region: (try { $env.AWS_REGION })
   }
}

export def add-tags-variable [variables: record, path: string] {
    if not ($path | path exists) {
        print $"warning: '($path)' does not exist."
        print $"warning: skipping tags."
        return $variables
    }

    return {
        ...$variables,
        tags: (open $path)
    }
}

export def read-variables [path: string] {
    if not ($path | path exists) {
        print $"error: '($path)' does not exist, please rename `sample.variables.toml` to `variables.toml` and add your domain name."
        exit
    }

    return (open $path)
}

export def validate-variables-or-exit [variables: record] {
    try { $variables.domain_name } catch {
        print "error: `domain_name` not found, please add it to the config/variables.toml file"
        exit
    }
}
