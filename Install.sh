#!/usr/bin/env bash

SCRIPT_BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ULTISNIPS_REPO_DIR="${SCRIPT_BASEDIR}/UltiSnips"
ULTISNIPS_LOCAL_DIR="${HOME}/.vim/UltiSnips"

MANUAL_MERGE_TOOL="meld"

function Sync
{
  if [ "${#}" -ne 2 ]; then
    >&2 printf "Fatal: %s\n%s %d %s\n%s" "wrong invocation of Install method." \
        "Expected exactly two arguments, but" "${#}" "have been provided." \
        "Aborting."
    exit 1
  fi

  printed_name="$(basename "${1}")"
  printf "Checking: %s\n" "${printed_name}"

  if [ ! -f "${1}" ]; then
    >&2 printf "%s \"%s\" %s\n%s\n%s\n" \
        "Fatal: source file" "${1}" "does not exist." \
        "Please fix the Install script." \
        "Aborting."
    exit 1
  fi

  TARGET_PARENT_DIR="$(basename "${2}")"

  if [ ! -f "${2}" ]; then
    printf "  -> Target not found, installing... "
    mkdir -p "${TARGET_PARENT_DIR}" && cp "${1}" "${2}"
    if [ "${?}" -eq 0 ]; then
      printf "done.\n"
    else
      printf "failed.\n"
    fi
  else
    if cmp "${1}" "${2}" >/dev/null 2>&1; then
      printf "  -> Files are identical.\n"
    else
      printf "  -> Files differ, invoking %s tool...\n" "${MANUAL_MERGE_TOOL}"
      printf -v cmd "%s %s %s" "${MANUAL_MERGE_TOOL}" "${1}" "${2}"
      eval "${cmd}"
    fi
  fi
}

function Ask
{
  local ans
  while true; do
    printf "%s [y/N]: " "${1}"
    read ans </dev/tty
    if [ -z "${ans}" ]; then
      ans="N"
    fi

    case "${ans}" in
      Y*|y*) return 0 ;;
      N*|n*) return 1 ;;
    esac
  done
}

REPO_SNIPPET_FILEPATHS=("$(find "${ULTISNIPS_REPO_DIR}" -name "*.snippets" 2>/dev/null)")
LOCAL_SNIPPET_FILEPATHS=("$(find "${ULTISNIPS_LOCAL_DIR}" -name "*.snippets" 2>/dev/null)")

REPO_SNIPPET_FILENAMES=()
for snippet_filepath in ${REPO_SNIPPET_FILEPATHS[@]}; do
  REPO_SNIPPET_FILENAMES+=("${snippet_filepath#${ULTISNIPS_REPO_DIR}/}")
done

LOCAL_SNIPPET_FILENAMES=()
for snippet_filepath in ${LOCAL_SNIPPET_FILEPATHS[@]}; do
  LOCAL_SNIPPET_FILENAMES+=("${snippet_filepath#${ULTISNIPS_LOCAL_DIR}/}")
done

printf "%s\n" "1. Installing snippet files..."
for snippet_file in "${REPO_SNIPPET_FILENAMES[@]}"; do
  Sync "${ULTISNIPS_REPO_DIR}/${snippet_file}" "${ULTISNIPS_LOCAL_DIR}/${snippet_file}"
done


printf "%s\n" "2. Checking if new local snippets are present..."
for snippet_file in "${LOCAL_SNIPPET_FILENAMES[@]}"; do
  is_unique=true
  for entry in "${REPO_SNIPPET_FILENAMES[@]}"; do
    if [[ "${snippet_file}" == "${entry}" ]]; then
      is_unique=false
      break
    fi
  done

  if ${is_unique}; then
    printf -v prompt "Introduce file \"%s\" to VimUltiSnips?" "${snippet_file}"

    if Ask "${prompt}"; then
      cp -v "${ULTISNIPS_LOCAL_DIR}/${snippet_file}" "${ULTISNIPS_REPO_DIR}/${snippet_file}"
    fi
  fi
done

printf "=== Done. ===\n"
