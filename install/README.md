# Setup AWS EKS

This is a Bash script that installs AWS CLI, `aws-iam-authenticator`, and `kubectl` on macOS machines with Apple Silicon processors.

## Prerequisites

- macOS machine with Apple Silicon processor
- Bash shell, version 5.x.x

```bash
# Check your bash version
$ bash --version

# Install bash via brew if it's an older version
$ brew install bash

# Open a new terminal
$ bash --version
```

- sudo permission
- AWS profile (e.g. `suite-dev`, `suite-prod`)

## Usage

1. Clone the repository
2. Navigate to the directory containing the script
3. Run the script using the following command:

```bash
./silicon-macOS.sh
```

This is a bash script that installs and configures some command-line tools on macOS. Here's an overview of the variables and functions defined in the script:

## Variables

- `ERROR_COLOR`, `INFO_COLOR`, `REQUIRED_COLOR`, `WARNING_COLOR`, and `NO_COLOR`: variables that contain ANSI escape codes for different colors used by the `color_echo` function to print colored messages to the terminal.
- `AWS_PROFILES`: an array of AWS profiles that the script should configure.
- `COMMANDS`: an array of commands that the script should install and configure (`aws`, `aws-iam-authenticator`, and `kubectl`).
- `AWS_IAM_AUTH_VERSION`: the version of `aws-iam-authenticator` to install.
- `AWS_IAM_AUTH_DOWNLOAD_URL`: the download URL for `aws-iam-authenticator`.
- `KUBE_VERSION`: the version of `kubectl` to install.
- `KUBE_DOWNLOAD_URL`: the download URL for `kubectl`.
- `ZSHRC_FILE`: the path to the `.zshrc` file.
- `CUSTOM_RC_FILE`: the path to a custom rc file.
- `BIN_DIR`: the directory where the script should install the command-line tools.
- `ADD_HOME_BIN_PATH`: a string that adds the `$HOME/bin` directory to the `PATH` environment variable.

## Functions

- `color_echo()`: a function that takes a color code and a message as arguments and prints the message in the specified color to the terminal.
- `download_file()`: a function that takes a URL and a filename as arguments and downloads the file from the URL using `curl`.
- `install_aws()`: a function that installs the AWS CLI.
- `install_aws-iam-authenticator()`: a function that installs `aws-iam-authenticator`.
- `install_kubectl()`: a function that installs `kubectl`.
- `commands_version()`: a function that takes a command as an argument and prints its version to the terminal.
- `add_custom_rc()`: a function that adds the custom rc command to the `.zshrc` file.
- `add_path_to_custom_rc()`: a function that adds `$HOME/bin` to the `PATH` environment variable in the custom rc file.

## To-do

- [ ] Support for Intel-based Macs.
