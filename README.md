# codeql-container

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Actions Status](https://github.com/btnguyen2k/codeql-container/workflows/ci/badge.svg)](https://github.com/btnguyen2k/codeql-container/actions)
[![Release](https://img.shields.io/github/release/btnguyen2k/codeql-container.svg?style=flat-square)](RELEASE-NOTES.md)

This project aims at making it easier to start using [GitHub CodeQL](https://github.com/github/codeql) by packaging [CodeQL CLI](https://github.com/github/codeql-cli-binaries) together with precompiled CodeQL queries in a Docker image.

You can build our own Docker image from the provided Dockerfile or use the [prebuilt image](https://hub.docker.com/r/btnguyen2k/codeql-container) to start using CodeQL CLI and run queries on your projects without installing it on your local machine.

## Usage

Start running CodeQL queries on your project with a single command:

```shell
$ docker run --rm -v "<source-code-directory>:/opt/src" -v "<results-directory>:/opt/results" btnguyen2k/codeql-container <command> [options]
```

**Input/Output directories**

- `source-code-directory`: The directory containing the source code to scan, must map this directory to the container's `/opt/src` directory.
- `results-directory`: The directory to store the scan results, must map this directory to the container's `/opt/results` directory.

**Commands**

| Command             | Description                                       |
|---------------------|---------------------------------------------------|
| `help`              | Print the help information and exit               |
| `security`          | Run the security and quality analyzing query pack |
| `security-extended` | Run the security analyzing extended query pack    |
| `scan`              | Run the standard code scanning query pack         |

**Options**

| Option                                 | Required | Default Value  | Description                                                                        |
|----------------------------------------|----------|----------------|------------------------------------------------------------------------------------|
| `-l=language` or `--language=language` | true     |                | The programming language of the source code to scan, for example `--language=java` |
| `-o=format` or `--output=format`       | false    | `sarif-latest` | The output format of the scan results, for example `--output=csv`                  |
| `--override`                           | false    |                | Override the results directory if it is not empty                                  |

- Supported output formats includes `csv` or `sarif`. See [CodeQL CLI documentation](https://docs.github.com/en/code-security/codeql-cli/getting-started-with-the-codeql-cli/analyzing-your-code-with-codeql-queries#running-codeql-database-analyze) for more details.
- Supported languages: see [CodeQL CLI documentation](https://docs.github.com/en/code-security/codeql-cli/getting-started-with-the-codeql-cli/preparing-your-code-for-codeql-analysis#running-codeql-database-create) for more details.

Example:

```shell
$ docker run -it --rm -v "$(pwd):/opt/src" -v "/tmp:/opt/results" btnguyen2k/codeql-container security --override --language=go --output=csv
```

## Credits

This project draws inspiration from the [microsoft/codeql-container repository](https://github.com/microsoft/codeql-container) and incorporates insights from [travisgosselin's comment](https://github.com/microsoft/codeql-container/issues/53#issuecomment-1875879512).

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Support and Contribution

Feel free to create [pull requests](https://github.com/btnguyen2k/codeql-container/pulls) or [issues](https://github.com/btnguyen2k/codeql-container/issues) to report bugs or suggest new features.
Please search the existing issues before filing new issues to avoid duplicates. For new issues, file your bug or feature request as a new issue.

If you find this project useful, please start it.
