#!/bin/bash

RESET="\033[0m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
WHITE="\033[37m"
BOLD="\033[1m"

print_red() {
    echo -e "${RED}${1}${RESET}"
}

print_green() {
    echo -e "${GREEN}${1}${RESET}"
}

print_yellow() {
    echo -e "${YELLOW}${1}${RESET}"
}

print_white() {
    echo -e "${WHITE}${1}${RESET}"
}

print_blue() {
    echo -e "${BLUE}${1}${RESET}"
}

print_normal() {
    echo -e "${RESET}${1}${RESET}"
}

# parse parameters
script_name=$(basename "$0")
src_dir="/opt/src"
results_dir="/opt/results"
COMMAND="$1"
OUTPUT_FORMAT="sarif-latest"
shift

for i in "$@"; do
    case $i in
        -l=*|--lang=*|--language=*)
            LANGUAGE="${i#*=}"
            shift # past argument=value
            ;;
        -l|--lang|--language)
            LANGUAGE="$2"
            shift 2 # past argument and value
            ;;
        -o=*|--output=*|--output-format=*)
            OUTPUT_FORMAT="${i#*=}"
            shift # past argument=value
            ;;
        -o|--output|--output-format)
            OUTPUT_FORMAT=$2
            shift 2 # past argument and value
            ;;
        --override)
            OVERRIDE_RESULTS_DIR=true
            shift # past argument with no value
            ;;
        *)
            ;;
    esac
done

print_info() {
    print_blue   "${BOLD}CodeQL-container version v${VERSION}"
    print_normal ""
}

do_help() {
    print_info
    print_normal "Usage: docker run --rm -v \"<source-code-directory>:${src_dir}\" -v \"<results-directory>:${results_dir}\" <docker-image> <command> [options]"
    print_normal ""
    print_normal "Docker:"
    print_normal "  <source-code-directory>    The directory containing the source code to scan, for example ${BLUE}${BOLD}\$(pwd)"
    print_normal "  <results-directory>        The directory to store the scan results, for example ${BLUE}${BOLD}~/codeql/myapp"
    print_normal "  <docker-image>             The docker image to run, for example ${BLUE}${BOLD}btnguyen2k/codeql-container"
    print_normal ""
    print_normal "Commands:"
    print_normal "  help                       Print the help information and exit"
    print_normal "  security                   Analyze security and quality"
    print_normal "  security-extended          Analyze security and quality (extended)"
    print_normal "  scan                       Code scanning"
    print_normal ""
    print_normal "Options:"
    print_normal "  -l, --language             The programming language of the source code to scan, for example ${BLUE}${BOLD}java"
    print_normal "  -o, --output               The output format of the scan results, for example ${BLUE}${BOLD}sarifv2.1.0"
    print_normal "      --override             Override the results directory if it is not empty"
    print_normal ""
}

check_directories() {
    # check if ${src_dir} and ${results_dir} are mapped
    if [ ! -d "${src_dir}" ]; then
        print_red "Error: Source code directory ${src_dir} is not mapped!"
        do_help
        exit 1
    fi
    if [ ! -d "${results_dir}" ]; then
        print_red "Error: Results directory ${results_dir} is not mapped!"
        do_help
        exit 1
    fi

    # check if ${results_dir} is empty or $(OVERRIDE_RESULTS_DIR) is true
    if [ ! -z "$(ls -A ${results_dir})" ]; then
        if [ "${OVERRIDE_RESULTS_DIR}" != "true" ]; then
            print_red "Error: Results directory ${results_dir} is not empty!"
            do_help
            exit 1
        fi
    fi
}

check_language() {
    if [ -z "${LANGUAGE}" ]; then
        print_red "Error: Language is not specified!"
        do_help
        exit 1
    fi
}

do_analyze() {
    print_info

    print_yellow "Creating the CodeQL database. This might take some time depending on the size of the project..."
    print_blue   "DEBUG: codeql database create --overwrite --language=${LANGUAGE} -s ${src_dir} ${results_dir}/codeql-db"
    codeql database create --overwrite --language=${LANGUAGE} -s ${src_dir} ${results_dir}/codeql-db
    if [ $? -eq 0 ]
    then
        print_green "\nCreated the database" 
    else
        print_red "\nFailed to create the database"
        exit 1
    fi

    output_file="${results_dir}/codeql-results.${OUTPUT_FORMAT}"
    if [[ "${OUTPUT_FORMAT}" =~ ^sarif.* ]]; then
        output_file="${results_dir}/codeql-results.sarif"
    fi
    print_yellow "\nRunning the Security and Quality rules on the project..."
    QUERIES="$1"
    print_blue   "DEBUG: codeql database analyze --format=${OUTPUT_FORMAT} --output=${output_file} ${results_dir}/codeql-db ${LANGUAGE}-${QUERIES}.qls"
    codeql database analyze --format=${OUTPUT_FORMAT} --output=${output_file} ${results_dir}/codeql-db ${LANGUAGE}-${QUERIES}.qls
    if [ $? -eq 0 ]
    then
        print_green "\nQuery execution successful" 
    else
        print_red "\nQuery execution failed\n"
        exit 1
    fi

    [ $? -eq 0 ] && print_yellow "\nDone. The results are saved at ${output_file}"
}

case $COMMAND in
    security)
        check_directories
        check_language
        do_analyze "security-and-quality"
        ;;
    security-extended)
        check_directories
        check_language
        do_analyze "security-and-quality"
        ;;
    scan)
        check_directories
        check_language
        do_analyze "code-scanning"
        ;;
    *)
        do_help
        ;;
esac
