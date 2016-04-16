#/bin/zsh

create_files() {
    if [[ ! -a "$FZF_MARKS_DIRMARKS" ]]; then
        touch "$FZF_MARKS_DIRMARKS"
    fi
    if [[ ! -a "$FZF_MARKS_FILEMARKS" ]]; then
        touch "$FZF_MARKS_FILEMARKS"
    fi
}

# fzf_bookmark_dir () {
#     local curr_dir="${PWD} # $*"
#     if [[ ! grep -Fxq "$curr_dir" ~ ]]; then
#         echo "$curr_dir" >> ~/.cdg_paths
#     fi
# }

echo_file() {
    # strip out comments, empty lines
    # cat "$1" | sed 's/#.*//g' | sed '/^\s*$/d'
    cat "$1" | sed '/^\s*$/d'
}

echo_hashes() {
    # user defined named directories
    hash -d | grep -v '_' | sed 's/.*=//'
}

echo_dirstack() {
    dirs -vp | awk '{print $2}'
}

echo_merged() {
    # merge FZF_MARKS_DIRMARKS and FZF_MARKS_FILEMARKS
    # awk deletes duplicates
    echo -e "$(echo_file $FZF_MARKS_FILEMARKS)\n$(echo_file $FZF_MARKS_DIRMARKS)\n$(echo_dirstack)\n$(echo_hashes)" | awk '!x[$0]++'
}

is_dir() {
    if [[ -d $1 ]]; then
        return 0
    else
        return 1
    fi
}

is_text_file() {
    if [[ $(file $1 | awk '{print $NF}') == 'text' ]]; then
        return 0
    else
        return 1
    fi
}

is_file() {
    if [[ -a $1 ]]; then
        return 0
    else
        return 1
    fi
}

open_choice() {
    if is_dir $1 &> /dev/null
    then
        eval ${FZF_MARKS_DIR_ACTION} "$1"
    elif is_text_file $1 &> /dev/null
    then
        eval ${FZF_MARKS_TEXT_ACTION} "$1"
    elif is_file $1 &> /dev/null
    then
        eval ${FZF_MARKS_FILE_ACTION} "$1"
    else
        echo "'$1' not found. Update your bookmarks file ('$FZF_MARKS_DIRMARKS' || '$FZF_MARKS_FILEMARKS')."
    fi
}

fzf_mark() {
    local choice=$(echo_merged | fzf)
    eval choice=$choice         # eval == evil
    open_choice $choice
}


create_files
fzf_mark
