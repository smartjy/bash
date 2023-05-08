# setup commands

This is a Bash script that installs AWS CLI, aws-iam-authenticator, and kubectl on macOS machines with Apple Silicon processors.

## Prerequisites

- macOS machine with Apple Silicon processor
- Bash shell, version 5.x.x
- sudo permmission
- aws profile (e.g suite-dev, suite-prod)

## Usage

1. Clone the repository
2. Navigate to the directory containing the script
3. Run the script using the following command:

```bash
./silicon-macOS.sh
```

The script will check if the machine is running macOS and Apple Silicon, and will then proceed to install AWS CLI, aws-iam-authenticator, and kubectl. The installed versions will be displayed after installation.

## Variables

The script uses the following variables:

- `COMMANDS`: an array containing the names of the commands to be installed.
- `AWS_IAM_AUTH_VERSION`: the version number of the aws-iam-authenticator.
- `AWS_IAM_AUTH_DOWNLOAD_URL`: the URL to download the aws-iam-authenticator.
- `KUBE_VERSION`: the version number of kubectl.
- `KUBE_DOWNLOAD_URL`: the URL to download kubectl.
- `ZSHRC_FILE`: the path to the `.zshrc` file.
- `CUSTOM_RC_FILE`: the path to a custom rc file.
- `BIN_DIR`: the path to the directory where the commands will be installed.
- `ADD_HOME_BIN_PATH`: the command to add the `$HOME/bin` path to the `$PATH` environment variable.
- `AWS_PROFILES`: an array containing the names of the AWS profiles to be configured.

## Functions

The script uses the following functions:

- `color_echo`: prints colored messages.
- `download_file`: downloads a file from a given URL.
- `install_aws`: installs AWS CLI.
- `install_aws-iam-authenticator`: installs aws-iam-authenticator.
- `install_kubectl`: installs kubectl.
- `commands_version`: returns the version of a command.

## License

This script is licensed under the [MIT License](https://opensource.org/licenses/MIT).