#!/usr/bin/env bash

# tfws-profile - Export AWS_PROFILE based on current terraform workspace
# Usage: eval "$(tfws-profile.sh)"

# Check if we're in a terraform directory and it's initialized
check_terraform_initialized() {
    # Fast check: look for .terraform directory and terraform.tfstate file
    if [[ ! -d ".terraform" ]] || [[ ! -f ".terraform/terraform.tfstate" ]]; then
        echo "Please run \`terraform init\` first!" >&2
        exit 1
    fi
}

# Get current terraform workspace
get_current_workspace() {
    if command -v terraform >/dev/null 2>&1; then
        terraform workspace show 2>/dev/null
    else
        # Fallback: read from .terraform/environment file if terraform command is not available
        # If the file doesn't exist, we're on the default workspace
        if [[ -f ".terraform/environment" ]]; then
            cat ".terraform/environment"
        else
            echo "default"
        fi
    fi
}

# Map workspace to AWS profile
map_workspace_to_profile() {
    local workspace="$1"
    local profile=""

    case "$workspace" in
    # Default workspace
    "default")
        profile="bright_devops_admin"
        ;;
    # d + digit patterns: d1, aue1_d1, auw2_d1, aue1d1, auw2-d1, etc.
    d[0-9]* | au[ew][12]d[0-9]* | au[ew][12][-_]d[0-9]*)
        profile="bright_dev_admin"
        ;;
    # t + digit patterns: t1, aue1_t1, auw2_t1, aue1t1, auw2-t1, etc.
    t[0-9]* | au[ew][12]t[0-9]* | au[ew][12][-_]t[0-9]*)
        profile="bright_test_admin"
        ;;
    # p + digit patterns: p1, aue1_p1, auw2_p1, aue1p1, auw2-p1, etc.
    p[0-9]* | au[ew][12]p[0-9]* | au[ew][12][-_]p[0-9]*)
        profile="bright_prd_admin"
        ;;
    # d + letter patterns: da, aue1_da, auw2_da, aue1da, auw2-da, etc.
    d[a-zA-Z]* | au[ew][12]d[a-zA-Z]* | au[ew][12][-_]d[a-zA-Z]*)
        profile="saas_dev_admin"
        ;;
    # t + letter patterns: ta, aue1_ta, auw2_ta, aue1ta, auw2-ta, etc.
    t[a-zA-Z]* | au[ew][12]t[a-zA-Z]* | au[ew][12][-_]t[a-zA-Z]*)
        profile="saas_test_admin"
        ;;
    # p + letter patterns: pa, aue1_pa, auw2_pa, aue1pa, auw2-pa, etc.
    p[a-zA-Z]* | au[ew][12]p[a-zA-Z]* | au[ew][12][-_]p[a-zA-Z]*)
        profile="saas_prd_admin"
        ;;
    # All others
    *)
        profile="bright_devops_admin"
        ;;
    esac

    echo "$profile"
}

# Main execution
main() {
    # Check if terraform is initialized
    check_terraform_initialized

    # Get current workspace
    local workspace
    workspace=$(get_current_workspace)

    if [[ -z "$workspace" ]]; then
        echo "Could not determine terraform workspace" >&2
        exit 1
    fi

    # Map workspace to AWS profile
    local aws_profile
    aws_profile=$(map_workspace_to_profile "$workspace")

    # Export the AWS_PROFILE variable
    echo "export AWS_PROFILE='$aws_profile'"
}

# Run main function
main "$@"
