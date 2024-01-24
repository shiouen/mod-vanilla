export def get-config [] {
    let aws_region = try { $env.AWS_REGION } catch { "us-east-1" }

    return {
        aws_region: $aws_region
    }
}
