export def --env get-config [path: string] {
    if not ($path | path exists) {
        print $"warning: '($path)' does not exist"
        print $"warning: skipping dotenv config"
        return {}
    }

    return (open $path)
}

export def --env load-config [path: string] {
    print "info: loading dotenv config..."
    load-env (get-config $path)
}
