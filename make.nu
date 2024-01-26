use scripts

scripts dotenv load-config "./config/.env.toml"

def deploy [approve: bool = false, destroy: bool = false] {
    let config = scripts config get-config "./config/variables.toml" "./config/tags.toml"

    print $config

    cd ./infra
    $config | to json | save --force variables.json

    terraform init

    mut options = [
        "apply",
        "-var-file",
        "variables.json"
    ]

    if $approve {
        $options = ($options | append "-auto-approve")
    }

    if $destroy {
        $options = ($options | append "-destroy")
    }

    run-external terraform ...$options
}

def "main deploy" [--approve (-a), --destroy (-d)] {
    deploy $approve $destroy
}

def main [] {}
