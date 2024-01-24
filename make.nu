use scripts

const dns_path = "infra/dns"

def deploy-dns [] {
}

def "main deploy" [] {
    scripts dotenv load-config "./config/.env.json"
    let config = scripts config get-config
    print $config
}

def main [] {}
